//
//  SJUserReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/25.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJUserReferenceViewController.h"
#import "SJMyReferenceCell.h"
#import "SJMyNeiCan.h"
#import "SJNetManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJUserReferenceDetailViewController.h"

@interface SJUserReferenceViewController ()<UITableViewDelegate,UITableViewDataSource,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *userReferenceArr;

@end

@implementation SJUserReferenceViewController

- (NSMutableArray *)userReferenceArr
{
    if (_userReferenceArr == nil)
    {
        _userReferenceArr = [NSMutableArray array];
    }
    return _userReferenceArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    
    // 设置表格属性
    [self setUpTableView];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewUserListData)];
    // 开始加载
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewUserListData];
    // 添加上拉加载
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreUserListData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 加载用户内参列表
- (void)loadNewUserListData
{
    i = 1;

    [self.userReferenceArr removeAllObjects];
    
    [netManager requestMyNeiCanListWithUserid:self.user_id andPageindex:[NSString stringWithFormat:@"%i",i] andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //SJLog(@"%@",dict);
        
        NSArray *tmpArr = [SJMyNeiCan objectArrayWithKeyValuesArray:dict[@"reference"]];
        
        if (tmpArr.count)
        {
            [self.userReferenceArr addObjectsFromArray:tmpArr];
            
            [self.tableView headerEndRefreshing];
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView headerEndRefreshing];
        }
        
        // 如果没有数据，显示默认页
        if (!self.userReferenceArr.count) {
            [SJNoDataView showNoDataViewToView:self.view];
        } else {
            [SJNoDataView hideNoDataViewFromView:self.view];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多用户内参列表
- (void)loadMoreUserListData
{
    i = i + 1;
    
    [netManager requestMyNeiCanListWithUserid:self.user_id andPageindex:[NSString stringWithFormat:@"%i",i] andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        
        //NSLog(@"%@",dict);
        
        NSArray *tmpArr = [SJMyNeiCan objectArrayWithKeyValuesArray:dict[@"reference"]];
        
        if (tmpArr.count)
        {
            [self.userReferenceArr addObjectsFromArray:tmpArr];
            
            [self.tableView footerEndRefreshing];
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView footerEndRefreshing];
        }
        
    } andFailBlock:^(NSError *error) {
        
        [self.tableView footerEndRefreshing];
        
    }];
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *nib = [UINib nibWithNibName:@"SJMyReferenceCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"SJMyReferenceCell"];
}

#pragma mark - UITableViewDataSource  代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userReferenceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyReferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJMyReferenceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.userReference = self.userReferenceArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 155;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyNeiCan *userReference = self.userReferenceArr[indexPath.row];
    SJUserReferenceDetailViewController *userReferenceDetailVC = [[SJUserReferenceDetailViewController alloc] init];
    userReferenceDetailVC.title = @"内参详情";
    userReferenceDetailVC.referenceid = userReference.reference_id;
    
    [self.navigationController pushViewController:userReferenceDetailVC animated:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewUserListData];
}

@end

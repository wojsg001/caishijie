//
//  SJTeacherReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 18/3/28.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJTeacherReferenceViewController.h"
#import "SJMyReferenceCell.h"
#import "SJMyNeiCan.h"
#import "SJNetManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJTeacherReferenceDetailViewController.h"
#import "SJCreateNewReferenceViewController.h"

@interface SJTeacherReferenceViewController ()<UITableViewDelegate,UITableViewDataSource,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *teacherReferenceArr;

@end

@implementation SJTeacherReferenceViewController

- (NSMutableArray *)teacherReferenceArr
{
    if (_teacherReferenceArr == nil)
    {
        _teacherReferenceArr = [NSMutableArray array];
    }
    return _teacherReferenceArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    
    // 设置表格属性
    [self setUpTableView];
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewTeacherListData)];
    // 添加上拉加载
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreTeacherListData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_inner_fabu"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewReference)];
    
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 开始加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewTeacherListData];
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *nib = [UINib nibWithNibName:@"SJMyReferenceCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"SJMyReferenceCell"];
}

#pragma mark - 创建新内参
- (void)createNewReference
{
    SJCreateNewReferenceViewController *createNewReferenceVC = [[SJCreateNewReferenceViewController alloc] init];
    createNewReferenceVC.title = @"发表新内参";
    
    [self.navigationController pushViewController:createNewReferenceVC animated:YES];
}

#pragma mark - 加载投顾内参数据
- (void)loadNewTeacherListData
{
    i = 1;
    
    [self.teacherReferenceArr removeAllObjects];
    
    [netManager requestTeacherNeiCanListWithUserid:self.user_id andPageindex:[NSString stringWithFormat:@"%i",i] andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //SJLog(@"%@",dict);
        
        NSArray *tmpArr = [SJMyNeiCan objectArrayWithKeyValuesArray:dict[@"reference"]];
        
        if (tmpArr.count)
        {
            [self.teacherReferenceArr addObjectsFromArray:tmpArr];
            
            [self.tableView headerEndRefreshing];
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView headerEndRefreshing];
        }
        
        // 如果没有数据，显示默认页
        if (!self.teacherReferenceArr.count) {
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

#pragma mark - 加载更多投顾内参数据
- (void)loadMoreTeacherListData
{
    i = i + 1;
    
    [netManager requestTeacherNeiCanListWithUserid:self.user_id andPageindex:[NSString stringWithFormat:@"%i",i] andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        
        
        NSArray *tmpArr = [SJMyNeiCan objectArrayWithKeyValuesArray:dict[@"reference"]];
        
        if (tmpArr.count)
        {
            [self.teacherReferenceArr addObjectsFromArray:tmpArr];
            
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

#pragma mark - UITableViewDataSource  代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teacherReferenceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyReferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJMyReferenceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.teacherReferenceArr.count)
    {
        cell.teacherReference = self.teacherReferenceArr[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 155;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyNeiCan *teacherReference = self.teacherReferenceArr[indexPath.row];
    SJTeacherReferenceDetailViewController *teacherReferenceDetailVC = [[SJTeacherReferenceDetailViewController alloc] init];
    teacherReferenceDetailVC.title = @"内参详情";
    teacherReferenceDetailVC.referenceid = teacherReference.reference_id;
    
    [self.navigationController pushViewController:teacherReferenceDetailVC animated:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewTeacherListData];
}

@end

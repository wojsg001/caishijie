//
//  SJHisReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHisReferenceViewController.h"
#import "SJHisReferenceCell.h"
#import "SJMyNeiCan.h"
#import "SJNetManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJHisReferenceDetailViewController.h"
#import "SJNeiCanPayViewController.h"
#import "SJMixPayParam.h"
#import "SJUserInfo.h"
#import "SJGoldPay.h"
#import "SJLoginViewController.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "SJGiftModel.h"

@interface SJHisReferenceViewController ()<UITableViewDelegate,UITableViewDataSource,SJHisReferenceCellDelegate>
{
    SJNetManager *netManager;
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJHisReferenceViewController

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(247, 247, 249);
    netManager = [SJNetManager sharedNetManager];
    
    // 设置表格属性
    [self setUpTableView];
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewHisReferenceData)];
    // 添加上拉加载
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreHisReferenceData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadNewHisReferenceData];
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    
    UINib *nib = [UINib nibWithNibName:@"SJHisReferenceCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SJHisReferenceCell"];
}

#pragma mark - 加载他的内参列表
- (void)loadNewHisReferenceData
{
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/my", HOST];
    NSDictionary *dic = @{@"userid":self.user_id,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"5"};
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 已登录
        SJToken *instance = [SJToken sharedToken];
        urlStr = [NSString stringWithFormat:@"%@/mobile/reference/findteacherreference",HOST];
        dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":self.user_id,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"5"};
    }
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"++%@",respose);
        [self.tableView headerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            
            NSArray *tmpArr = [SJMyNeiCan objectArrayWithKeyValuesArray:respose[@"data"][@"reference"]];
            if (tmpArr.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
            
            // 如果没有数据，显示默认页
            if (!self.dataArray.count) {
                [SJNoDataView showNoDataViewToView:self.view];
            } else {
                [SJNoDataView hideNoDataViewFromView:self.view];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.tableView headerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 加载更多他的内参列表
- (void)loadMoreHisReferenceData
{
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/my",HOST];
    NSDictionary *dic = @{@"userid":self.user_id,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"5"};
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 已登录
        SJToken *instance = [SJToken sharedToken];
        urlStr = [NSString stringWithFormat:@"%@/mobile/reference/findteacherreference",HOST];
        dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":self.user_id,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"5"};
    }
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"++%@",respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJMyNeiCan objectArrayWithKeyValuesArray:respose[@"data"][@"reference"]];
            if (tmpArr.count) {
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource  代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJHisReferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHisReferenceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    if (self.dataArray.count) {
        cell.hisReference = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyNeiCan *model = self.dataArray[indexPath.row];
    SJHisReferenceDetailViewController *hisReferenceVC = [[SJHisReferenceDetailViewController alloc] init];
    hisReferenceVC.title = @"内参详情";
    hisReferenceVC.referenceid = model.reference_id;
    
    [self.navigationController pushViewController:hisReferenceVC animated:YES];
}

#pragma mark - SJHisReferenceCellDelegate 代理方法
- (void)didClickPayButtonWith:(SJMyNeiCan *)model {
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
//        SJGiftModel *model = [[SJGiftModel alloc] init];
//        model.gift_id = hisReference.reference_id;
//        model.gift_name = @"内参";
//        model.price = hisReference.price;
//        [SJPayView showSJPayViewWithGiftModel:model targetid:hisReference.user_id itemtype:@"20"];
        SJNeiCanPayViewController *payVC = [[SJNeiCanPayViewController alloc] init];
        payVC.model = model;
        [self.navigationController pushViewController:payVC animated:YES];
    } else {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

@end

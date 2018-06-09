//
//  SJPersonalReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalReferenceViewController.h"
#import "SJPersonalReferenceCell.h"
#import "SJMyNeiCan.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"
#import "SJHisReferenceDetailViewController.h"
#import "SJNetManager.h"
#import "SJMixPayParam.h"
#import "SJGoldPay.h"
#import "SJGiftModel.h"
#import "SJNeiCanPayViewController.h"

@interface SJPersonalReferenceViewController ()<UITableViewDelegate, UITableViewDataSource, SJNoWifiViewDelegate>
{
    NSInteger i;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJPersonalReferenceViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setupTableView];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewReferenceData];
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewReferenceData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreReferenceData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
    // 接收登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(-0.5, 0, 0, 0));
    }];
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJPersonalReferenceCell" bundle:nil] forCellReuseIdentifier:@"SJPersonalReferenceCell"];
}

- (void)loadNewReferenceData {
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/my", HOST];
    NSDictionary *dic = @{@"userid":self.target_id, @"pageindex":@(i), @"pagesize":@(5)};
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 已登录
        SJToken *instance = [SJToken sharedToken];
        urlStr = [NSString stringWithFormat:@"%@/mobile/reference/findteacherreference",HOST];
        dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":self.target_id,@"pageindex":@(i),@"pagesize":@(5)};
    }
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        SJLog(@"%@", respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJMyNeiCan objectArrayWithKeyValuesArray:respose[@"data"][@"reference"]];
            if (tmpArray.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArray];
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
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadMoreReferenceData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/my", HOST];
    NSDictionary *dic = @{@"userid":self.target_id, @"pageindex":@(i), @"pagesize":@(5)};
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 已登录
        SJToken *instance = [SJToken sharedToken];
        urlStr = [NSString stringWithFormat:@"%@/mobile/reference/findteacherreference",HOST];
        dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":self.target_id,@"pageindex":@(i),@"pagesize":@(5)};
    }
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJMyNeiCan objectArrayWithKeyValuesArray:respose[@"data"][@"reference"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - 接收通知处理方法
- (void)loginSuccess {
    [self loadNewReferenceData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJPersonalReferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJPersonalReferenceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
        WS(weakSelf);
        cell.clickedPayButtonBlock = ^() {
            [weakSelf payReferenceWith:self.dataArray[indexPath.row]];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 141;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJMyNeiCan *model = self.dataArray[indexPath.row];
    SJHisReferenceDetailViewController *hisReferenceVC = [[SJHisReferenceDetailViewController alloc] init];
    hisReferenceVC.title = @"内参详情";
    hisReferenceVC.referenceid = model.reference_id;
    
    [self.navigationController pushViewController:hisReferenceVC animated:YES];
}

- (void)payReferenceWith:(SJMyNeiCan *)referencemodel {
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
//        SJGiftModel *model = [[SJGiftModel alloc] init];
//        model.gift_id = referencemodel.reference_id;
//        model.gift_name = @"内参";
//        model.price = referencemodel.price;
//        [SJPayView showSJPayViewWithGiftModel:model targetid:referencemodel.user_id itemtype:@"20"];
        SJNeiCanPayViewController *payVC = [[SJNeiCanPayViewController alloc] init];
        payVC.model = referencemodel;
        [self.navigationController pushViewController:payVC animated:YES];
    } else {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES) {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadNewReferenceData];
    }
}

@end

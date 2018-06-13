//
//  SJMineFansViewController.m
//  CaiShiJie
//
//  Created by user on 16/10/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMineFansViewController.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJMineFansViewCell.h"
#import "SJMineFansModel.h"
#import "SJChatMessageViewController.h"

@interface SJMineFansViewController ()<UITableViewDelegate, UITableViewDataSource, SJNoWifiViewDelegate>
{
    NSInteger i;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJMineFansViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setupSubViews];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMineFansData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadMineFansData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreMineFansData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setupSubViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(-0.5, 0, 0, 0));
    }];
}

- (void)loadMineFansData {
    i = 1;
    NSString *url = [NSString stringWithFormat:@"%@&pagesize=10&pageindex=%@", self.urlStr, @(i)];
    [SJhttptool GET:url paramers:nil success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        SJLog(@"%@", respose);
        if ([respose[@"status"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJMineFansModel objectArrayWithKeyValuesArray:respose[@"data"][@"attention"]];
            if (tmpArray.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
            
            if (!self.dataArray.count) {
                [SJNoDataView showNoDataViewToView:self.view];
            } else {
                [SJNoDataView hideNoDataViewFromView:self.view];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
        SJLog(@"%@", error);
    }];
}

- (void)loadMoreMineFansData {
    i = i + 1;
    NSString *url = [NSString stringWithFormat:@"%@&pagesize=10&pageindex=%@", self.urlStr, @(i)];
    [SJhttptool GET:url paramers:nil success:^(id respose) {        [self.tableView footerEndRefreshing];
        if ([respose[@"status"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJMineFansModel objectArrayWithKeyValuesArray:respose[@"data"][@"attention"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView footerEndRefreshing];
        SJLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJMineFansViewCell *cell = [SJMineFansViewCell cellWithTableView:tableView];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SJMineFansModel *model = self.dataArray[indexPath.row];
    SJChatMessageViewController *chatMessageVC = [[SJChatMessageViewController alloc] init];
    chatMessageVC.navigationItem.title = model.nickname;
    chatMessageVC.target_id = model.user_id;
    [self.navigationController pushViewController:chatMessageVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - SJNoDataViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES) {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadMineFansData];
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

//
//  SJPrepaidViewController.m
//  CaiShiJie
//
//  Created by user on 16/7/28.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPrepaidViewController.h"
#import "SJConsumeCell.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJUserConsumeParam.h"
#import "SJBillModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface SJPrepaidViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int j; // 分页
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJPrepaidViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    netManager = [SJNetManager sharedNetManager];
    self.isNetwork = YES;
    
    // 设置表格属性
    [self setUpTableView];
    
    // 加载全部账单数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadConsumeData:self.status];
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewData)];
    // 添加上拉加载
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshNetwork];
}

- (void)loadNewData
{
    [self loadConsumeData:self.status];
}

- (void)loadMoreData
{
    [self loadMoreConsumeData:self.status];
}

#pragma mark - 设置表格
- (void)setUpTableView
{
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    WS(weakSelf);
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view);
        make.left.mas_equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view);
        make.right.mas_equalTo(weakSelf.view);
    }];
    
    UINib *nib = [UINib nibWithNibName:@"SJConsumeCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SJConsumeCell"];
}

#pragma mark - 加载全部账单数据
- (void)loadConsumeData:(NSString *)status
{
    j = 1;
    
    SJToken *instance = [SJToken sharedToken];
    SJUserConsumeParam *consumeParam = [[SJUserConsumeParam alloc] init];
    consumeParam.pageindex = [NSString stringWithFormat:@"%i",j];
    consumeParam.pagesize = @"10";
    consumeParam.status = status;
    consumeParam.type = @"1";
    consumeParam.token = instance.token;
    consumeParam.userid = instance.userid;
    consumeParam.time = instance.time;
    
    [netManager requestUserConsumeWithParam:consumeParam success:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        NSArray *tmpArray = [SJBillModel objectArrayWithKeyValuesArray:dict[@"order"]];
        if (!tmpArray.count) {
            // 如果没有获取到数据返回主线程
            [SJNoDataView showNoDataViewToView:self.view];
        } else {
            [SJNoDataView hideNoDataViewFromView:self.view];
            
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:tmpArray];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多全部账单数据
- (void)loadMoreConsumeData:(NSString *)status
{
    j++;
    
    SJToken *instance = [SJToken sharedToken];
    SJUserConsumeParam *consumeParam = [[SJUserConsumeParam alloc] init];
    consumeParam.pageindex = [NSString stringWithFormat:@"%i",j];
    consumeParam.pagesize = @"10";
    consumeParam.status = status;
    consumeParam.type = @"1";
    consumeParam.token = instance.token;
    consumeParam.userid = instance.userid;
    consumeParam.time = instance.time;
    
    [netManager requestUserConsumeWithParam:consumeParam success:^(NSDictionary *dict) {
        
        [self.tableView footerEndRefreshing];
        
        NSArray *tmpArray = [SJBillModel objectArrayWithKeyValuesArray:dict[@"order"]];
        if (!tmpArray.count) {
            return ;
        } else {
            [self.dataArray addObjectsFromArray:tmpArray];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJConsumeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJConsumeCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.billModel = self.dataArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadConsumeData:self.status];
    }
}

@end

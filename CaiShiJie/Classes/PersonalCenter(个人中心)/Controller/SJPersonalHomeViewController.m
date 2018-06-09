//
//  SJPersonalHomeViewController.m
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalHomeViewController.h"
#import "SJhttptool.h"
#import "SJPersonalHomeModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJPersonalHomeCell.h"
#import "SDAutoLayout.h"
#import "SJLogDetailViewController.h"

#define kPassUserInfoNotification @"TeacherInfo"

@interface SJPersonalHomeViewController ()<UITableViewDelegate, UITableViewDataSource, SJNoWifiViewDelegate>
{
    NSInteger i;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *teacherInfoDic;

@end

@implementation SJPersonalHomeViewController

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
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadPersonalHomeData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTeacherInfoData:) name:kPassUserInfoNotification object:nil];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadPersonalHomeData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMorePersonalHomeData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)loadPersonalHomeData {
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/talk/findmessage?userid=%@&pageindex=%@&pagesize=10", HOST, self.target_id, @(i)];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"status"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJPersonalHomeModel objectArrayWithKeyValuesArray:respose[@"data"]];
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
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadMorePersonalHomeData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/talk/findmessage?userid=%@&pageindex=%@&pagesize=10", HOST, self.target_id, @(i)];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"status"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJPersonalHomeModel objectArrayWithKeyValuesArray:respose[@"data"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - NSNotification
- (void)getTeacherInfoData:(NSNotification *)n {
    self.teacherInfoDic = (NSDictionary *)n.object;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJPersonalHomeCell *cell = [SJPersonalHomeCell cellWithTableView:tableView];
    if (self.teacherInfoDic) {
        cell.teacherInfoDic = self.teacherInfoDic;
    }
    if (self.dataArray.count) {
        
        cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJPersonalHomeModel *model = self.dataArray[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SJPersonalHomeCell class] contentViewWidth:SJScreenW];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJPersonalHomeModel *model = self.dataArray[indexPath.row];
    if (([model.types isEqualToString:@"1"] && [model.item_type isEqualToString:@"22"]) || ([model.types isEqualToString:@"3"] && [model.item_type isEqualToString:@"22"])) {
        SJLogDetailViewController *logDetailVC = [[SJLogDetailViewController alloc] init];
        logDetailVC.article_id = model.item_id;
        [self.navigationController pushViewController:logDetailVC animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES) {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadPersonalHomeData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

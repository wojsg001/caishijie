//
//  SJCSJMessageViewController.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCSJMessageViewController.h"
#import "SJCSJMessageCell.h"
#import "SJCSJMessageModel.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface SJCSJMessageViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger i;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJCSJMessageViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(247, 247, 248);
    [self setupTableView];
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stock_del_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessage)];
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadCSJMessageData];
    [self.tableView addHeaderWithTarget:self action:@selector(loadCSJMessageData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreCSJMessageData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_tableView registerNib:[UINib nibWithNibName:@"SJCSJMessageCell" bundle:nil] forCellReuseIdentifier:@"SJCSJMessageCell"];
    self.tableView.estimatedRowHeight = 85;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)loadCSJMessageData {
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/msg-system/all?pagesize=10&page=%@", HOST, @(i)];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        SJLog(@"%@", respose);
        if ([respose[@"status"] integerValue]) {
            NSArray *tmpArray = [SJCSJMessageModel objectArrayWithKeyValuesArray:respose[@"data"][@"msg"]];
            if (tmpArray.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        SJLog(@"%@", error);
    }];
}

- (void)loadMoreCSJMessageData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/msg-system/all?pagesize=10&page=%@", HOST, @(i)];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        [self.tableView footerEndRefreshing];
        if ([respose[@"status"] integerValue]) {
            NSArray *tmpArray = [SJCSJMessageModel objectArrayWithKeyValuesArray:respose[@"data"][@"msg"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        SJLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJCSJMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJCSJMessageCell"];
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - ClickEnvet
- (void)deleteAllMessage {
    // do something
}

@end

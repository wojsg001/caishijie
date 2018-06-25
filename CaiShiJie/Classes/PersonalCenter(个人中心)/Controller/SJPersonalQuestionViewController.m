//
//  SJPersonalQuestionViewController.m
//  CaiShiJie
//
//  Created by user on 18/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalQuestionViewController.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJPersonalQuestionModel.h"
#import "SJPersonalQuestionFrame.h"
#import "SJPersonalQuestionCell.h"
#import "SJQuestionDetailController.h"

@interface SJPersonalQuestionViewController ()<UITableViewDelegate, UITableViewDataSource, SJNoWifiViewDelegate>
{
    NSInteger i;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *itemArray;

@end

@implementation SJPersonalQuestionViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setupTableView];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadQuestionData];
    [self.tableView addHeaderWithTarget:self action:@selector(loadQuestionData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreQuestionData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
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
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)loadQuestionData {
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/question/all",HOST];
    NSDictionary *paramers = @{@"userid":self.target_id,@"pageindex":@(i),@"pagesize":@(10),@"answer":@"1"};
    [SJhttptool GET:urlStr paramers:paramers success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = respose[@"data"][@"question"];
            if (tmpArray.count) {
                [self.dataArray removeAllObjects];
                [self.itemArray removeAllObjects];
                for (NSDictionary *tmpDic in tmpArray) {
                    NSData *data = [tmpDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    SJPersonalQuestionModel *model = [SJPersonalQuestionModel objectWithKeyValues:dic];
                    SJPersonalQuestionFrame *modelFrame = [[SJPersonalQuestionFrame alloc] init];
                    modelFrame.model = model;
                    [self.dataArray addObject:modelFrame];
                    [self.itemArray addObject:[NSString stringWithFormat:@"%@", tmpDic[@"item_id"]]];
                }
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
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadMoreQuestionData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/question/all",HOST];
    NSDictionary *paramers = @{@"userid":self.target_id,@"pageindex":@(i),@"pagesize":@(10),@"answer":@"1"};
    [SJhttptool GET:urlStr paramers:paramers success:^(id respose) {
        //SJLog(@"%@",respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = respose[@"data"][@"question"];
            if (tmpArray.count) {
                for (NSDictionary *tmpDic in tmpArray) {
                    NSData *data = [tmpDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    SJPersonalQuestionModel *model = [SJPersonalQuestionModel objectWithKeyValues:dic];
                    SJPersonalQuestionFrame *modelFrame = [[SJPersonalQuestionFrame alloc] init];
                    modelFrame.model = model;
                    [self.dataArray addObject:modelFrame];
                    [self.itemArray addObject:[NSString stringWithFormat:@"%@", tmpDic[@"item_id"]]];
                }
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJPersonalQuestionCell *cell = [SJPersonalQuestionCell cellWithTableView:tableView];
    if (self.dataArray.count) {
        cell.modelFrame = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count) {
        SJPersonalQuestionFrame *modelFrame = self.dataArray[indexPath.row];
        return modelFrame.cellHeight;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.itemArray.count) {
        SJQuestionDetailController *detailVC = [[SJQuestionDetailController alloc] init];
        detailVC.item = self.itemArray[indexPath.row];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES) {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadQuestionData];
    }
}

@end

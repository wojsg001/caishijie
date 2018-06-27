//
//  SJBlogRankViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogRankViewController.h"
#import "SJBlogRankCell.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "SJhttptool.h"
#import "SJBlogRankModel.h"
#import "SJLogDetailViewController.h"

@interface SJBlogRankViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJBlogRankViewController

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadLogRankData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadLogRankData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreLogRankData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJBlogRankCell" bundle:nil] forCellReuseIdentifier:@"SJBlogRankCell"];
}

#pragma mark - 加载日志排行数据
- (void)loadLogRankData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findallorder",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"20"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJBlogRankModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            
            if (tmpArr.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
            
            if (!self.dataArray.count) {
                // 如果没有数据，显示提示页
                [SJNoDataView showNoDataViewToView:self.view];
            } else {
                [SJNoDataView hideNoDataViewFromView:self.view];
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - 加载更多日志排行数据
- (void)loadMoreLogRankData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findallorder",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJBlogRankModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            
            if (tmpArr.count)
            {
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SJBlogRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJBlogRankCell"];
    cell.sortLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
    if (indexPath.row == 0) {
        cell.sortLabel.textColor = RGB(255, 178, 48);
    }
    else if (indexPath.row == 1) {
        cell.sortLabel.textColor = RGB(217, 67, 50);
    }
    else if (indexPath.row == 2) {
        cell.sortLabel.textColor = RGB(24, 181, 238);
    }
    else {
        cell.sortLabel.textColor = RGB(153, 153, 153);
    }
    
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SJBlogRankModel *model = self.dataArray[indexPath.row];
    SJLogDetailViewController *logDetailVC = [[SJLogDetailViewController alloc] init];
    logDetailVC.article_id = model.article_id;
    
    [self.navigationController pushViewController:logDetailVC animated:YES];
}

@end

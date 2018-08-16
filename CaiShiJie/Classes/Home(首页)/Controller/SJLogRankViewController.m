//
//  SJLogRankViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLogRankViewController.h"
#import "SJLogCell.h"
#import "SJRecommendLog.h"
#import "SJRecommendLogFrame.h"
#import "SJLogDetailViewController.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface SJLogRankViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i; // 分页
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJLogRankViewController

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格
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
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 加载日志排行数据
- (void)loadLogRankData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/pop",HOST];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%i",i],@"pageSize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJRecommendLog objectArrayWithKeyValuesArray:respose[@"data"]];
            
            if (tmpArr.count)
            {
                [self.dataArray removeAllObjects];
                // 模型数组->视图模型
                for (SJRecommendLog *logModel in tmpArr)
                {
                    SJRecommendLogFrame *logFrame = [[SJRecommendLogFrame alloc] init];
                    logFrame.logModel = logModel;
                    [self.dataArray addObject:logFrame];
                }
            }
            
            [self.tableView reloadData];
            
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

#pragma mark - 加载更多日志排行数据
- (void)loadMoreLogRankData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/pop",HOST];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%i",i],@"pageSize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];

        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJRecommendLog objectArrayWithKeyValuesArray:respose[@"data"]];
            
            if (tmpArr.count)
            {
                // 模型数组->视图模型
                for (SJRecommendLog *logModel in tmpArr)
                {
                    SJRecommendLogFrame *logFrame = [[SJRecommendLogFrame alloc] init];
                    logFrame.logModel = logModel;
                    [self.dataArray addObject:logFrame];
                }
            }
            
            [self.tableView reloadData];
            
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
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
    SJLogCell *cell = [SJLogCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.dataArray.count > 0)
    {
        cell.logFrame = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count)
    {
        SJRecommendLogFrame *logFrame = self.dataArray[indexPath.row];
        return logFrame.cellH;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJRecommendLogFrame *logFrame = self.dataArray[indexPath.row];
    SJLogDetailViewController *logDetailVC = [[SJLogDetailViewController alloc] init];
    logDetailVC.article_id = logFrame.logModel.article_id;
    
    [self.navigationController pushViewController:logDetailVC animated:YES];
}

@end

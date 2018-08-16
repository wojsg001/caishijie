//
//  SJShaiZhanJiViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJShaiZhanJiViewController.h"
#import "SJBlogArticlePublicCell.h"
#import "SJhttptool.h"
#import "SJBlogArticleModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJLogDetailViewController.h"

@interface SJShaiZhanJiViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJShaiZhanJiViewController

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
    // 加载早晚评数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadShaiZhanJiData];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadShaiZhanJiData)];
    // 添加下拉获取更多数据
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreShaiZhanJiData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJBlogArticlePublicCell" bundle:nil] forCellReuseIdentifier:@"SJBlogArticlePublicCell"];
}

- (void)loadShaiZhanJiData
{
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbytype",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10",@"type":@"3"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
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
        SJLog(@"%@",error);
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)loadMoreShaiZhanJiData
{
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbytype",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10",@"type":@"3"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            if (tmpArr.count) {
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SJBlogArticlePublicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJBlogArticlePublicCell"];
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SJBlogArticleModel *model = self.dataArray[indexPath.row];
    SJLogDetailViewController *detailVC = [[SJLogDetailViewController alloc] initWithNibName:@"SJLogDetailViewController" bundle:nil];
    detailVC.article_id = model.article_id;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end

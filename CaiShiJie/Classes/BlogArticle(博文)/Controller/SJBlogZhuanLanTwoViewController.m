//
//  SJBlogZhuanLanTwoViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/27.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogZhuanLanTwoViewController.h"
#import "SJZhuanLanTwoCell.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "SJBlogZhuanLanModel.h"
#import "MJRefresh.h"
#import "SJPersonalArticleViewController.h"

@interface SJBlogZhuanLanTwoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJBlogZhuanLanTwoViewController

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
    
    // 加载初始化数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewZhuanLanData];
    // 添加下拉刷新控件
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewZhuanLanData)];
    // 添加上拉加载控件
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreZhuanLanData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setUpTableView
{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJZhuanLanTwoCell" bundle:nil] forCellReuseIdentifier:@"SJZhuanLanTwoCell"];
}

#pragma mark - 加载初始化数据
- (void)loadNewZhuanLanData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/column/index",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogZhuanLanModel objectArrayWithKeyValuesArray:respose[@"data"][@"column"]];
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
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)loadMoreZhuanLanData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/column/index",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogZhuanLanModel objectArrayWithKeyValuesArray:respose[@"data"][@"column"]];
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
        [self.tableView footerEndRefreshing];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJZhuanLanTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJZhuanLanTwoCell"];
    
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SJBlogZhuanLanModel *model = self.dataArray[indexPath.row];
    SJPersonalArticleViewController *personalArticleVC = [[SJPersonalArticleViewController alloc] init];
    
    personalArticleVC.userid = model.user_id;
    personalArticleVC.title = @"他的博文";
    
    [self.navigationController pushViewController:personalArticleVC animated:YES];
}

@end

//
//  SJBlogZhuanTiViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogZhuanTiViewController.h"
#import "SJBlogZhuanTiCell.h"
#import "SJhttptool.h"
#import "SJBlogZhuanTiModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "KINWebBrowserViewController.h"

@interface SJBlogZhuanTiViewController ()<UITableViewDelegate,UITableViewDataSource,KINWebBrowserDelegate>
{
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJBlogZhuanTiViewController

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
    [self loadBlogZhuanTiData];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadBlogZhuanTiData)];
    // 添加下拉获取更多数据
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreBlogZhuanTiData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJBlogZhuanTiCell" bundle:nil] forCellReuseIdentifier:@"SJBlogZhuanTiCell"];
}

#pragma mark - 加载初始化专题数据
- (void)loadBlogZhuanTiData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/subject/index",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};

    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogZhuanTiModel objectArrayWithKeyValuesArray:respose[@"data"][@"subject"]];
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
        //SJLog(@"%@",error);
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}
#pragma mark - 加载更多专题数据
- (void)loadMoreBlogZhuanTiData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/subject/index",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"%@",respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogZhuanTiModel objectArrayWithKeyValuesArray:respose[@"data"][@"subject"]];
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
        //SJLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SJBlogZhuanTiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJBlogZhuanTiCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69 + (SJScreenW - 30)/690 * 306;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJBlogZhuanTiModel *model = self.dataArray[indexPath.row];
    
    KINWebBrowserViewController *webBrowserVC = [KINWebBrowserViewController webBrowser];
    [webBrowserVC setDelegate:self];
    [webBrowserVC loadURLString:model.url];
    webBrowserVC.tintColor = [UIColor whiteColor];
    
    [self.navigationController pushViewController:webBrowserVC animated:YES];
}

#pragma mark - KINWebBrowserDelegate
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error {
    [MBHUDHelper showWarningWithText:@"加载失败！"];
}

@end

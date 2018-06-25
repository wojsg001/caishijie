//
//  SJPersonalArticleViewController.m
//  CaiShiJie
//
//  Created by user on 18/3/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalArticleViewController.h"
#import "SJLogCell.h"
#import "SJRecommendLog.h"
#import "SJRecommendLogFrame.h"
#import "MJExtension.h"
#import "SJNetManager.h"
#import "MJRefresh.h"
#import "SJLogDetailViewController.h"

@interface SJPersonalArticleViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    SJNetManager *netManager;
    
    int i; // 博文分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *blogArticleArrM;

@end

@implementation SJPersonalArticleViewController

- (NSMutableArray *)blogArticleArrM
{
    if (_blogArticleArrM == nil)
    {
        _blogArticleArrM = [NSMutableArray array];
    }
    return _blogArticleArrM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    // 设置表格
    [self setUpTableView];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadBlogArticleData)];
    
    // 添加下拉获取更多数据
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreBlogArticleData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
    
    // 添加自动下拉刷新
    [self.tableView headerBeginRefreshing];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 加载博文数据
- (void)loadBlogArticleData
{
    i = 1;
    
    [netManager requestPersonalArticleListWithPageindex:[NSString stringWithFormat:@"%i",i] andPagesize:@"10" anduserid:_userid withSuccessBlock:^(id dict) {
        
        //SJLog(@"%@",dict);
        
        NSArray *tmpArr = [SJRecommendLog objectArrayWithKeyValuesArray:dict[@"article"]];
        // 模型->视图模型
        [self.blogArticleArrM removeAllObjects];
        for (SJRecommendLog *logModel in tmpArr)
        {
            SJRecommendLogFrame *logFrame = [[SJRecommendLogFrame alloc] init];
            logFrame.logModel = logModel;

            [self.blogArticleArrM addObject:logFrame];
        }

        [self.tableView headerEndRefreshing];
        [self.tableView reloadData];
        
        if (!self.blogArticleArrM.count) {
            [SJNoDataView showNoDataViewToView:self.view];
        } else {
            [SJNoDataView hideNoDataViewFromView:self.view];
        }
        
    } andFailBlock:^(NSError *error) {
        
        [self.tableView headerEndRefreshing];
        SJLog(@"%@",error);
        
    }];
}
#pragma mark - 加载更多博文数据
- (void)loadMoreBlogArticleData
{
    i = i + 1;
    [netManager requestPersonalArticleListWithPageindex:[NSString stringWithFormat:@"%i",i] andPagesize:@"5" anduserid:_userid withSuccessBlock:^(NSDictionary *dict) {
        
        //SJLog(@"%@",dict[@"article"]);
        NSArray *tmpArr = [SJRecommendLog objectArrayWithKeyValuesArray:dict[@"article"]];
        
        // 模型->视图模型
        for (SJRecommendLog *logModel in tmpArr)
        {
            SJRecommendLogFrame *logFrame = [[SJRecommendLogFrame alloc] init];
            logFrame.logModel = logModel;
            
            [self.blogArticleArrM addObject:logFrame];
            //SJLog(@"%ld",self.blogArticleArrM.count);
        }
        
        [self.tableView footerEndRefreshing];
        [self.tableView reloadData];
        
        
    } andFailBlock:^(NSError *error) {
        
        [self.tableView footerEndRefreshing];
        
    }];
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.blogArticleArrM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJLogCell *cell = [SJLogCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // 传递模型
    cell.logFrame = self.blogArticleArrM[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJRecommendLogFrame *logFrame = self.blogArticleArrM[indexPath.row];
    
    return logFrame.cellH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJRecommendLogFrame *logFrame = self.blogArticleArrM[indexPath.row];
    
    SJLogDetailViewController *detailVC = [[SJLogDetailViewController alloc] initWithNibName:@"SJLogDetailViewController" bundle:nil];
    detailVC.article_id = logFrame.logModel.article_id;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end

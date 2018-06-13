//
//  SJUserNoAnswerViewController.m
//  CaiShiJie
//
//  Created by user on 16/7/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserNoAnswerViewController.h"
#import "SJWeiHuiDaCell.h"
#import "SJWeiHuiDaFrame.h"
#import "SJWeiHuiDaModel.h"
#import "SJNetManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface SJUserNoAnswerViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int j; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *questionArr;

@end

@implementation SJUserNoAnswerViewController

- (NSMutableArray *)questionArr
{
    if (_questionArr == nil)
    {
        _questionArr = [NSMutableArray array];
    }
    return _questionArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    // 设置表格
    [self setUpTableView];
    // 加载我的未回答问题数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMyNoAnswerQuestionList];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadMyNoAnswerQuestionList)];
    // 添加上拉刷新按钮
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreMyNoAnswerQuestionList)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

#pragma mark - 设置表格属性
- (void)setUpTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.noDataView.hidden = YES;
}

#pragma mark - 加载我的未回答问题数据
- (void)loadMyNoAnswerQuestionList
{
    j = 1;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [netManager requestMyQuestionListWithUserid:[d valueForKey:kUserid] andPageindex:[NSString stringWithFormat:@"%i",j] andPagesize:@"10" andAnswer:@"0" withSuccessBlock:^(NSDictionary *dict) {
        
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //SJLog(@"++%@",dict[@"question"]);
        NSArray *tmpArr = [SJWeiHuiDaModel objectArrayWithKeyValuesArray:dict[@"question"]];
        if (tmpArr.count) {
            self.tableView.hidden = NO;
            self.noDataView.hidden = YES;
            [self.questionArr removeAllObjects];
            // 模型->视图模型
            for (SJWeiHuiDaModel *WeiHuiDa in tmpArr)
            {
                SJWeiHuiDaFrame *WeiHuiDaHuiDaFrame = [[SJWeiHuiDaFrame alloc] init];
                WeiHuiDaHuiDaFrame.questionModel = WeiHuiDa;
                
                [self.questionArr addObject:WeiHuiDaHuiDaFrame];
            }
            [self.tableView reloadData];
        } else {
            // 无数据
            self.tableView.hidden = YES;
            self.noDataView.hidden = NO;
        }
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多我的未回答问题数据
- (void)loadMoreMyNoAnswerQuestionList
{
    j = j + 1;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [netManager requestMyQuestionListWithUserid:[d valueForKey:kUserid] andPageindex:[NSString stringWithFormat:@"%i",j] andPagesize:@"10" andAnswer:@"0" withSuccessBlock:^(NSDictionary *dict) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",dict[@"question"]);
        NSArray *tmpArr = [SJWeiHuiDaModel objectArrayWithKeyValuesArray:dict[@"question"]];
        if (tmpArr.count) {
            // 模型->视图模型
            for (SJWeiHuiDaModel *WeiHuiDa in tmpArr)
            {
                SJWeiHuiDaFrame *WeiHuiDaHuiDaFrame = [[SJWeiHuiDaFrame alloc] init];
                WeiHuiDaHuiDaFrame.questionModel = WeiHuiDa;
                
                [self.questionArr addObject:WeiHuiDaHuiDaFrame];
            }
            [self.tableView reloadData];
        }
    } andFailBlock:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJWeiHuiDaCell *cell = [SJWeiHuiDaCell cellWithTableView:tableView];
    
    if (self.questionArr.count)
    {
        cell.questionModelF = self.questionArr[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.questionArr.count) {
        SJWeiHuiDaFrame *questionF = self.questionArr[indexPath.row];
        
        return questionF.cellH;
    }
    return CGFLOAT_MIN;
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMyNoAnswerQuestionList];
}

- (void)dealloc {
    SJLog(@"%s",__func__);
}

@end

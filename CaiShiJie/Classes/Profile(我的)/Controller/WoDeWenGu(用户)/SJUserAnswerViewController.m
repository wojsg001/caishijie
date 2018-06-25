//
//  SJUserAnswerViewController.m
//  CaiShiJie
//
//  Created by user on 18/7/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserAnswerViewController.h"
#import "SJUserQuestionDetailViewController.h"
#import "SJYiJingHuiDaCell.h"
#import "SJYiJingHuiDaFrame.h"
#import "SJYiJingHuiDaModel.h"
#import "SJNetManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface SJUserAnswerViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *answerArr;

@end

@implementation SJUserAnswerViewController

- (NSMutableArray *)answerArr
{
    if (_answerArr == nil)
    {
        _answerArr = [NSMutableArray array];
    }
    return _answerArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    // 设置表格
    [self setUpTableView];
    // 加载我的已回答问题数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMyQuestionList];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadMyQuestionList)];
    // 添加上拉刷新按钮
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreMyQuestionList)];
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

#pragma mark - 加载我的已回答问题数据
- (void)loadMyQuestionList
{
    i = 1;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [netManager requestMyQuestionListWithUserid:[d valueForKey:kUserid] andPageindex:[NSString stringWithFormat:@"%i",i] andPagesize:@"10" andAnswer:@"1" withSuccessBlock:^(NSDictionary *dict) {
        
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //SJLog(@"%@",dict[@"question"]);
        NSArray *tmpArr = [SJYiJingHuiDaModel objectArrayWithKeyValuesArray:dict[@"question"]];
        if (tmpArr.count) {
            self.tableView.hidden = NO;
            self.noDataView.hidden = YES;
            [self.answerArr removeAllObjects];
            // 模型->视图模型
            for (SJYiJingHuiDaModel *YiJingHuiDa in tmpArr)
            {
                SJYiJingHuiDaFrame *YiJingHuiDaFrame = [[SJYiJingHuiDaFrame alloc] init];
                YiJingHuiDaFrame.YiJingHuiDaModel = YiJingHuiDa;
                
                [self.answerArr addObject:YiJingHuiDaFrame];
            }
            [self.tableView reloadData];
        } else {
            // 无数据
            self.tableView.hidden = YES;
            self.noDataView.hidden = NO;
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多我的已回答问题数据
- (void)loadMoreMyQuestionList
{
    i = i + 1;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [netManager requestMyQuestionListWithUserid:[d valueForKey:kUserid] andPageindex:[NSString stringWithFormat:@"%i",i] andPagesize:@"10" andAnswer:@"1" withSuccessBlock:^(NSDictionary *dict) {
        
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",dict[@"question"]);
        NSArray *tmpArr = [SJYiJingHuiDaModel objectArrayWithKeyValuesArray:dict[@"question"]];
        if (tmpArr.count) {
            // 模型->视图模型
            for (SJYiJingHuiDaModel *YiJingHuiDa in tmpArr)
            {
                SJYiJingHuiDaFrame *YiJingHuiDaFrame = [[SJYiJingHuiDaFrame alloc] init];
                YiJingHuiDaFrame.YiJingHuiDaModel = YiJingHuiDa;
                
                [self.answerArr addObject:YiJingHuiDaFrame];
            }
            [self.tableView reloadData];
        }
    } andFailBlock:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.answerArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJYiJingHuiDaCell *cell = [SJYiJingHuiDaCell cellWithTableView:tableView];
    
    if (self.answerArr.count)
    {
        cell.YiJingHuiDaFrame = self.answerArr[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.answerArr.count) {
        SJYiJingHuiDaFrame *answerF = self.answerArr[indexPath.row];
        return answerF.cellH;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJYiJingHuiDaFrame *answerF = self.answerArr[indexPath.row];
    
    SJUserQuestionDetailViewController *detailVC = [[SJUserQuestionDetailViewController alloc] init];
    detailVC.item_id = answerF.YiJingHuiDaModel.item_id;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMyQuestionList];
}

@end

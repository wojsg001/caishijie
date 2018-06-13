//
//  SJTeacherAnswerViewController.m
//  CaiShiJie
//
//  Created by user on 16/7/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJTeacherAnswerViewController.h"
#import "SJQuestionDetailController.h"
#import "SJAnsweredCell.h"
#import "SJAnswerModel.h"
#import "SJAnswerFrame.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface SJTeacherAnswerViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    int i; // 分页
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJTeacherAnswerViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadAnswetData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadAnswetData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreAnswetData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setUpTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.noDataView.hidden = YES;
}

- (void)loadAnswetData {
    i = 1;
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"userid":instance.userid,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10",@"answer":@"1"};
    NSString *urlStr =[NSString stringWithFormat:@"%@/mobile/question/all",HOST];
    [SJhttptool GET:urlStr paramers:param success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJAnswerModel objectArrayWithKeyValuesArray:respose[@"data"][@"question"]];
            if (tmpArray.count) {
                self.tableView.hidden = NO;
                self.noDataView.hidden = YES;
                [self.dataArray removeAllObjects];
                for (SJAnswerModel *model in tmpArray) {
                    SJAnswerFrame *fm = [[SJAnswerFrame alloc] init];
                    fm.answerModel = model;
                    [self.dataArray addObject:fm];
                }
                [self.tableView reloadData];
            } else {
                self.tableView.hidden = YES;
                self.noDataView.hidden = NO;
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取数据失败"];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadMoreAnswetData {
    i = i + 1;
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"userid":instance.userid,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10",@"answer":@"1"};
    NSString *urlStr =[NSString stringWithFormat:@"%@/mobile/question/all",HOST];
    [SJhttptool GET:urlStr paramers:param success:^(id respose) {
        //SJLog(@"%@",respose);

        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJAnswerModel objectArrayWithKeyValuesArray:respose[@"data"][@"question"]];
            if (tmpArray.count) {
                for (SJAnswerModel *model in tmpArray) {
                    SJAnswerFrame *fm = [[SJAnswerFrame alloc] init];
                    fm.answerModel = model;
                    [self.dataArray addObject:fm];
                }
                [self.tableView reloadData];
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取数据失败"];
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJAnsweredCell *cell = [SJAnsweredCell cellWithTableView:tableView];
    if (self.dataArray.count) {
        cell.answerModelF = self.dataArray[indexPath.row];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count) {
        SJAnswerFrame *answerF = self.dataArray[indexPath.row];
        return answerF.cellH;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SJAnswerFrame *answerF = self.dataArray[indexPath.row];
    SJQuestionDetailController *detailVC = [[SJQuestionDetailController alloc] init];
    detailVC.item = answerF.answerModel.item_id;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadAnswetData];
}

@end

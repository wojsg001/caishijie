//
//  SJTeacherQuestionViewController.m
//  CaiShiJie
//
//  Created by user on 16/7/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTeacherQuestionViewController.h"
#import "SJComposeViewController.h"
#import "SJQuestionCell.h"
#import "SJQuestionFrame.h"
#import "SJQuestionModel.h"
#import "SJToken.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJhttptool.h"

@interface SJTeacherQuestionViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    int i; // 分页
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJTeacherQuestionViewController

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
    [self loadQuestionData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadQuestionData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreQuestionData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setUpTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.noDataView.hidden = YES;
}

- (void)loadQuestionData {
    i = 1;
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"userid":instance.userid,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10",@"answer":@"0"};
    NSString *urlStr =[NSString stringWithFormat:@"%@/mobile/question/all",HOST];
    
    [SJhttptool GET:urlStr paramers:param success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJQuestionModel objectArrayWithKeyValuesArray:respose[@"data"][@"question"]];
            if (tmpArray.count) {
                self.tableView.hidden = NO;
                self.noDataView.hidden = YES;
                [self.dataArray removeAllObjects];
                for (SJQuestionModel *model in tmpArray) {
                    SJQuestionFrame *fm =[[SJQuestionFrame alloc]init];
                    fm.questionModel = model;
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

- (void)loadMoreQuestionData {
    i = i + 1;
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"userid":instance.userid,@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10",@"answer":@"0"};
    NSString *urlStr =[NSString stringWithFormat:@"%@/mobile/question/all",HOST];
    
    [SJhttptool GET:urlStr paramers:param success:^(id respose) {
        //SJLog(@"%@",respose);
        [self.tableView footerEndRefreshing];

        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJQuestionModel objectArrayWithKeyValuesArray:respose[@"data"][@"question"]];
            if (tmpArray.count) {
                for (SJQuestionModel *model in tmpArray) {
                    SJQuestionFrame *fm =[[SJQuestionFrame alloc]init];
                    fm.questionModel = model;
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
    SJQuestionCell *cell = [SJQuestionCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.dataArray.count) {
        cell.questionModelF = self.dataArray[indexPath.row];
    }
    
    cell.answerBtn.tag = indexPath.row;
    [cell.answerBtn addTarget:self action:@selector(answerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

// 点击回答按钮时
- (void)answerBtnPressed:(UIButton *)btn
{
    SJQuestionFrame *fm = self.dataArray[btn.tag];
    SJComposeViewController *composeVC = [[SJComposeViewController alloc] init];
    composeVC.title = [NSString stringWithFormat:@"回答「%@」问题", fm.questionModel.nickname];
    composeVC.itemid = fm.questionModel.item_id;
    composeVC.type = @"1";
    WS(weakSelf);
    composeVC.refreshData = ^(BOOL isRefresh) {
        if (isRefresh) {
            [weakSelf loadQuestionData];
        }
    };
    
    [self.navigationController pushViewController:composeVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count) {
        SJQuestionFrame *questionF = self.dataArray[indexPath.row];
        return questionF.cellH;
    }

    return CGFLOAT_MIN;
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadQuestionData];
}

@end

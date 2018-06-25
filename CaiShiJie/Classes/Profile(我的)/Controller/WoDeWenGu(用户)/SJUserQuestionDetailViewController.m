//
//  SJUserQuestionDetailViewController.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserQuestionDetailViewController.h"

#import "SJUserQuestionFrame.h"
#import "SJUserQuestionModel.h"
#import "SJUserQuestionCell.h"

#import "SJUserAnswerCell.h"
#import "SJUserAnswerFrame.h"
#import "SJUserAnswerModel.h"

#import "SJNetManager.h"
#import "MJExtension.h"

@interface SJUserQuestionDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    SJNetManager *netManager;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *questionArr;
@property (nonatomic, strong) NSMutableArray *answerArr;

@end

@implementation SJUserQuestionDetailViewController

- (NSMutableArray *)questionArr
{
    if (_questionArr == nil)
    {
        _questionArr = [NSMutableArray array];
    }
    return _questionArr;
}

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
    
    self.title = @"问答详情";
    [self setUpTableView];
    
    netManager = [SJNetManager sharedNetManager];
    
    // 加载问股详情数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadQuestionDetail];
}

- (void)setUpTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}
#pragma mark - 加载问股详情数据
- (void)loadQuestionDetail
{
    //SJLog(@"%@",self.item_id);
    
    [netManager requestMyQuestionDetailListWithItemid:self.item_id andPageindex:@"1" andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        NSLog(@"%@",dict);
        
        SJUserQuestionModel *question = [SJUserQuestionModel objectWithKeyValues:dict[@"Question"]];
        SJUserQuestionFrame *questionF = [[SJUserQuestionFrame alloc] init];
        questionF.questionModel = question;
        
        [self.questionArr addObject:questionF];
        
        
        NSArray *tmpArr = [SJUserAnswerModel objectArrayWithKeyValuesArray:dict[@"answer"]];
        
        // 模型->视图模型
        for (SJUserAnswerModel *answerM in tmpArr)
        {
            SJUserAnswerFrame *answerF = [[SJUserAnswerFrame alloc] init];
            answerF.answerModel = answerM;
            
            [self.answerArr addObject:answerF];
        }
        
        [self.tableView reloadData];
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        NSLog(@"%@",error);
    }];
}

#pragma mark - UITableViewDataSource Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return _questionArr.count;
    }
    else
    {
        return _answerArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 用户问题
    if (indexPath.section ==0)
    {
        SJUserQuestionCell *cell = [SJUserQuestionCell cellWithTableView:tableView];
        
        cell.questionModelF = _questionArr[indexPath.row];
        
        return cell;
    }
    // 老师回答
    else
    {
        SJUserAnswerCell *cell = [SJUserAnswerCell cellWithTableView:tableView];
        cell.answerModelF = _answerArr[indexPath.row];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        SJUserQuestionFrame *questionF = _questionArr[indexPath.row];
        
        return questionF.cellH;
    }
    else
    {
        SJUserAnswerFrame *answerF = _answerArr[indexPath.row];
        
        return answerF.cellH;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    else
    {
        return 0.01;
    }
}
    
@end

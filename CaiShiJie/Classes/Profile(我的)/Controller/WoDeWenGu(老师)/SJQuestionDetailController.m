//
//  SJQuestionDetailController.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJQuestionDetailController.h"
#import "SJQuestionDetailFrame.h"
#import "SJDetailModel.h"
#import "SJQuestionDetailCell.h"
#import "SJAnswerDetailCell.h"
#import "SJAnswerdetailModel.h"
#import "SJAnswerDetailFrame.h"
#import "SJhttptool.h"
#import "MJRefresh.h"

@interface SJQuestionDetailController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *arr5 ;
    NSInteger k;
    NSNumber *nuber1;
    NSMutableArray *arr4;
    NSMutableArray *_questionatrry2;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SJQuestionDetailController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadnew];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _questionarr = [NSMutableArray array];
    _questionatrry2 = [NSMutableArray array];
    _Answerarr1 = [NSMutableArray array];
    arr5 = [NSMutableArray array];
    arr4 = [NSMutableArray array];
    [self.tableView addFooterWithTarget:self action:@selector(loadmore)];
    [self.tableView addHeaderWithTarget:self action:@selector(loadnew)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
    
    self.title = @"问答详情";
    [self setUpTableView];
}

-(void)loadnew{
    [_questionatrry2 removeAllObjects];
    [arr5 removeAllObjects];
    [self loadSt];
    [self.tableView headerEndRefreshing];
}

-(void)loadmore{
    
    k=k+1;
    [arr4 removeAllObjects];
    nuber1 =[NSNumber numberWithInteger:k];
    [_questionatrry2 removeAllObjects];
    NSString *itemm =self.item;
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:nuber1,@"pageindex",@10,@"pagesize",itemm,@"itemid", nil];

    NSString *Details =[NSString stringWithFormat:@"%@/mobile/question/detail",HOST];
    
    [SJhttptool GET:Details paramers:paramers success:^(id respose) {
        //SJLog(@"%@",respose);
        NSDictionary *datadic =respose[@"data"];
        NSNumber *number =respose[@"states"];
        NSString *states =[NSString stringWithFormat:@"%@",number];
        if ([states  isEqualToString:@"1"]) {
            
            NSDictionary *question =datadic[@"Question"];
            //把这个字典传过去建立模型
            SJDetailModel *model = [SJDetailModel detailwith:question];
            // 模型转视图模型
            SJQuestionDetailFrame *modelF = [[SJQuestionDetailFrame alloc] init];
            modelF.questionDetailModel = model;
            
            [_questionatrry2 addObject:modelF];
            _questionarr = _questionatrry2;
            
            
            NSArray *answerArr =datadic[@"answer"];
            for (NSDictionary *dict in answerArr) {
                SJAnswerdetailModel *model =[SJAnswerdetailModel modelwithdic:dict];
                // 模型转视图模型
                SJAnswerDetailFrame *modelF = [[SJAnswerDetailFrame alloc] init];
                modelF.answerModel = model;
                [arr4 addObject:modelF];
            }
            
            [_Answerarr1 addObjectsFromArray:arr4];
            
            [self.tableView reloadData];
            [self.tableView footerEndRefreshing];
            
        }else if ([states isEqualToString:@"0"]){
            
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"错误提示!" message:@"网络不佳，请稍后。。。" delegate:self cancelButtonTitle:@" 确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        
    } failure:^(NSError *error) {
        UIAlertView *alert1 =[[UIAlertView alloc]initWithTitle:@"错误提示!" message:@"请求失败" delegate:self cancelButtonTitle:@" 确定" otherButtonTitles:nil, nil];
        [alert1 show];
        
        NSLog(@"%@",error);
    }];
}

-(void)loadSt{
    
    k=1;
    NSString *itemm =self.item;
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:@1,@"pageindex",@10,@"pagesize",itemm,@"itemid", nil];
    
    //SJLog(@"++++%@",paramers);
    
    NSString *Details =[NSString stringWithFormat:@"%@/mobile/question/detail",HOST];
    
    [SJhttptool GET:Details paramers:paramers success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        NSLog(@"%@",respose);
        NSDictionary *datadic =respose[@"data"];
        NSNumber *number =respose[@"states"];
        NSString *states =[NSString stringWithFormat:@"%@",number];
        if ([states isEqualToString:@"1"]) {
            NSDictionary *question =datadic[@"Question"];
            // 把这个字典传过去建立模型
            SJDetailModel *model = [SJDetailModel detailwith:question];
            // 模型转视图模型
            SJQuestionDetailFrame *modelF = [[SJQuestionDetailFrame alloc] init];
            modelF.questionDetailModel = model;
        
            [_questionatrry2 addObject:modelF];
            _questionarr = _questionatrry2;
            
            
            NSArray *answerArr = datadic[@"answer"];
            for (NSDictionary *dict in answerArr) {
                SJAnswerdetailModel *model = [SJAnswerdetailModel modelwithdic:dict];
                // 模型转视图模型
                SJAnswerDetailFrame *modelF = [[SJAnswerDetailFrame alloc] init];
                modelF.answerModel = model;
                
                [arr5 addObject:modelF];
            }
            
            _Answerarr1 = arr5;
            
            [self.tableView reloadData];
            
        }else if ([states isEqualToString:@"0"]){
            
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"错误提示!" message:@"网络不佳，请稍后。。。" delegate:self cancelButtonTitle:@" 确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        UIAlertView *alert1 =[[UIAlertView alloc]initWithTitle:@"错误提示!" message:@"请求失败" delegate:self cancelButtonTitle:@" 确定" otherButtonTitles:nil, nil];
        [alert1 show];
        
    }];
}

- (void)setUpTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
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
        return _questionarr.count;
    }
    else
    {
        return _Answerarr1.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        SJQuestionDetailCell *cell = [SJQuestionDetailCell cellWithTableView:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_questionarr.count > 0) {
            cell.questionDetailFrame = _questionarr[indexPath.row];
        }
        
        return cell;
    }
    else
    {
        SJAnswerDetailCell *cell = [SJAnswerDetailCell cellWithTableView:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_Answerarr1.count > 0) {
            cell.answerDetailFrame = _Answerarr1[indexPath.row];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_questionarr.count > 0) {
            SJQuestionDetailFrame *modelF = _questionarr[indexPath.row];
            return modelF.cellH;
        } else {
            return CGFLOAT_MIN;
        }
    } else{
        if (_Answerarr1.count > 0) {
            SJAnswerDetailFrame *modelF = _Answerarr1[indexPath.row];
            return modelF.cellH;
        } else {
            return CGFLOAT_MIN;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 15;
    }
    else
    {
        return 0.01;
    }
}

@end

//
//  SJQuestionRankViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJQuestionRankViewController.h"
#import "SJQuestionRankCell.h"
#import "SJQuestionRankPopView.h"
#import "SJhttptool.h"
#import "SJQuestionRankModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJComposeViewController.h"
#import "SJMyLiveViewController.h"
#import "SJUserInfo.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJLoginViewController.h"
#import "SJNewLiveRoomViewController.h"

@interface SJQuestionRankViewController ()<UITableViewDelegate,UITableViewDataSource,SJQuestionRankPopViewDelegate>
{
    int i; // 分页
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView                *popViewBackground;
@property (nonatomic, strong) SJQuestionRankPopView *popView;
@property (nonatomic, strong) NSMutableArray        *questionRankArray;
@property (nonatomic, strong) SJQuestionRankModel   *questionRankModel;

@end

@implementation SJQuestionRankViewController

- (NSMutableArray *)questionRankArray
{
    if (_questionRankArray == nil)
    {
        _questionRankArray = [NSMutableArray array];
    }
    return _questionRankArray;
}

- (UIView *)popViewBackground
{
    if (_popViewBackground == nil)
    {
        _popViewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH)];
        _popViewBackground.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.0];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDown:)];
        [_popViewBackground addGestureRecognizer:tapRecognizer];
        
    }
    return _popViewBackground;
}

- (SJQuestionRankPopView *)popView
{
    if (_popView == nil)
    {
        _popView = [[SJQuestionRankPopView alloc] initWithFrame:CGRectMake(0, SJScreenH, SJScreenW, SJScreenH)];
        _popView.delegate = self;
    }
    return _popView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格
    [self setUpTableView];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadQuestionRankData];
    
    // 添加上拉加载更多
    [self.tableView addHeaderWithTarget:self action:@selector(loadQuestionRankData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreQuestionRankData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.tableFooterView = [UIView new];
}
#pragma mark - 加载问答排行
- (void)loadQuestionRankData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/answerranking",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"20"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];

        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJQuestionRankModel objectArrayWithKeyValuesArray:respose[@"data"][@"question"]];
            
            if (tmpArr.count)
            {
                [self.questionRankArray removeAllObjects];
                [self.questionRankArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        if (self.showNoWifiViewBlock) {
            self.showNoWifiViewBlock();
        }
    }];
}

#pragma mark - 加载更多问答排行
- (void)loadMoreQuestionRankData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/answerranking",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJQuestionRankModel objectArrayWithKeyValuesArray:respose[@"data"][@"question"]];
            
            if (tmpArr.count)
            {
                [self.questionRankArray addObjectsFromArray:tmpArr];
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
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questionRankArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJQuestionRankCell *cell = [SJQuestionRankCell cellWithTableView:tableView];
    cell.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
    
    if (indexPath.row == 0)
    {
        cell.sortLabel.textColor = RGB(255, 178, 45);
    }
    else if (indexPath.row == 1)
    {
        cell.sortLabel.textColor = RGB(217, 67, 50);
    }
    else if (indexPath.row == 2)
    {
        cell.sortLabel.textColor = RGB(24, 181, 238);
    }
    else
    {
        cell.sortLabel.textColor = RGB(153, 153, 153);
    }
    
    if (self.questionRankArray.count)
    {
        SJQuestionRankModel *model = self.questionRankArray[indexPath.row];
        
        cell.sortLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
        cell.nameLabel.text = model.nickname;
        cell.questionCountLabel.text = model.show;
        
        cell.moreButton.tag = indexPath.row + 101;
        [cell.moreButton addTarget:self action:@selector(moreButtonClickDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - 更多按钮点击事件
- (void)moreButtonClickDown:(UIButton *)sender
{
    SJQuestionRankModel *model = self.questionRankArray[sender.tag - 101];
    self.questionRankModel = model;
    
    [self.popViewBackground addSubview:self.popView];
    [SJKeyWindow addSubview:self.popViewBackground];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.popViewBackground.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.5];
        CGRect rect = self.popView.frame;
        rect.origin.y = SJScreenH - 135;
        self.popView.frame =rect;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 点击手势响应事件
- (void)tapDown:(UITapGestureRecognizer *)tap
{
    [self removePopView];
}

- (void)removePopView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.popViewBackground.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.0];
        CGRect rect = self.popView.frame;
        rect.origin.y = SJScreenH;
        self.popView.frame =rect;
    } completion:^(BOOL finished) {
        [self.popView removeFromSuperview];
        [self.popViewBackground removeFromSuperview];
        self.popView = nil;
        self.popViewBackground = nil;
    }];
}

#pragma mark - SJQuestionRankPopViewDelegate 代理方法
- (void)questionRankPopView:(SJQuestionRankPopView *)questionRankPopView clickButtonDown:(NSInteger)index
{
    [self removePopView];
    
    switch (index) {
        case 101:
        {
            SJComposeViewController *composeVC = [[SJComposeViewController alloc] init];
            composeVC.title = [NSString stringWithFormat:@"向「%@」提问",self.questionRankModel.nickname];
            composeVC.targetid = self.questionRankModel.user_id;
            composeVC.type = @"0";
            
            [self.navigationController pushViewController:composeVC animated:YES];
        }
            break;
        case 102:
        {
            if ([self.questionRankModel.user_id isEqualToString:@"10412"]) {
                SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
                liveRoomVC.target_id = self.questionRankModel.user_id;
                [self.navigationController pushViewController:liveRoomVC animated:YES];
            } else {
//                SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//                NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
//                myLiveVC.user_id = [d valueForKey:kUserid];
//                myLiveVC.target_id = self.questionRankModel.user_id;
//                
//                [self.navigationController pushViewController:myLiveVC animated:YES];
            }
        }
            break;
        case 103:
        {
            if (![[SJUserInfo sharedUserInfo] isSucessLogined])
            {
                SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
                
                [self.navigationController pushViewController:loginVC animated:YES];
                
                return;
            }
            
            SJToken *Token = [SJToken sharedToken];
            
            [[SJNetManager sharedNetManager] addAttentionWithToken:Token.token andUserid:Token.userid andTime:Token.time andTargetid:self.questionRankModel.user_id withSuccessBlock:^(NSDictionary *dict) {
                if ([dict[@"status"] isEqual:@"1"]) {
                    // 提示用户关注成功
                    [MBProgressHUD showSuccess:@"关注成功"];
                } else {
                    [MBHUDHelper showWarningWithText:dict[@"data"]];
                }
            } andFailBlock:^(NSError *error) {
                [MBHUDHelper showWarningWithText:error.localizedDescription];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end

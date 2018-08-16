//
//  SJPeopleRankViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPeopleRankViewController.h"
#import "SJCustomCell.h"
#import "SJCustom.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJComposeViewController.h"
#import "SJMyLiveViewController.h"
#import "SJNewLiveRoomViewController.h"

@interface SJPeopleRankViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *attentionArray;

@end

@implementation SJPeopleRankViewController

- (NSMutableArray *)attentionArray
{
    if (_attentionArray == nil)
    {
        _attentionArray = [NSMutableArray array];
    }
    return _attentionArray;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格
    [self setUpTableView];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadPeopleRankData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadPeopleRankData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMorePeopleRankData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
    
    // 接收通知
    [self receiveNotification];
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 注册表格
    UINib *nib1 = [UINib nibWithNibName:@"SJCustomCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"SJCustomCell"];
}
#pragma mark - 加载人气排行数据
- (void)loadPeopleRankData
{
    // 如果登录过，先获取当前用户关注过的老师
    if ([[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        [self loadMineAttentionData];
    }
    
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/recommend/fire",HOST];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%i",i],@"pageSize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJCustom objectArrayWithKeyValuesArray:respose[@"data"]];
            
            if (tmpArr.count)
            {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
            }
            
            [self.tableView reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

#pragma mark - 加载更多人气排行数据
- (void)loadMorePeopleRankData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/recommend/fire",HOST];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%i",i],@"pageSize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJCustom objectArrayWithKeyValuesArray:respose[@"data"]];
            
            if (tmpArr.count)
            {
                [self.dataArray addObjectsFromArray:tmpArr];
            }
            
            [self.tableView reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - 加载用户关注过的老师
- (void)loadMineAttentionData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/focusteacher",HOST];
    SJToken *token = [SJToken sharedToken];
    
    [SJhttptool GET:urlStr paramers:token.keyValues success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            for (NSDictionary *dic in respose[@"data"])
            {
                NSString *str = [NSString stringWithFormat:@"%@",dic[@"attention_user_id"]];
                [self.attentionArray addObject:str];
            }
            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

#pragma mark - 接收通知
- (void)receiveNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitLogin) name:KNotificationExitLogin object:nil];
}

- (void)loginSuccess
{
    [self loadMineAttentionData];
}

- (void)exitLogin
{
    [self.attentionArray removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJCustomCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.dataArray.count)
    {
        SJCustom *model = self.dataArray[indexPath.row];
        cell.recommendMaster = model;
        
        if ([self.attentionArray containsObject:model.user_id])
        {
            [cell.attentionBtn setImage:[UIImage imageNamed:@"attention_icon2_h"] forState:UIControlStateNormal];
            cell.attentionBtn.enabled = NO;
        }
        else
        {
            [cell.attentionBtn setImage:[UIImage imageNamed:@"attention_icon2"] forState:UIControlStateNormal];
            cell.attentionBtn.enabled = YES;
        }
        
        // 加关注
        cell.attentionBtn.tag = indexPath.row;
        [cell.attentionBtn addTarget:self action:@selector(attentionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.attentionBtn setHidden:YES];
        // 咨询
        cell.zhixunBtn.tag = indexPath.row;
        [cell.zhixunBtn addTarget:self action:@selector(zhixunBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - 点击关注按钮
- (void)attentionBtnPressed:(UIButton *)btn
{
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }

    SJCustom *RQRank = self.dataArray[btn.tag];
    SJToken *Token = [SJToken sharedToken];
    
    [[SJNetManager sharedNetManager] addAttentionWithToken:Token.token andUserid:Token.userid andTime:Token.time andTargetid:RQRank.user_id withSuccessBlock:^(NSDictionary *dict) {
        
        if ([dict[@"status"] isEqual:@"1"]) {
            [btn setImage:[UIImage imageNamed:@"attention_icon2_h"] forState:UIControlStateNormal];
            btn.enabled = NO;
            // 提示用户关注成功
            [MBProgressHUD showSuccess:@"关注成功"];
        } else {
            [MBHUDHelper showWarningWithText:dict[@"data"]];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 点击咨询按钮
- (void)zhixunBtnPressed:(UIButton *)btn {
    SJCustom *RQRank = self.dataArray[btn.tag];
    SJComposeViewController *composeVC = [[SJComposeViewController alloc] init];
    composeVC.title = [NSString stringWithFormat:@"向「%@」提问",RQRank.nickname];
    composeVC.type = @"0";
    composeVC.targetid = RQRank.user_id;
    
    [self.navigationController pushViewController:composeVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    SJCustom *peopleRank = self.dataArray[indexPath.row];
    if ([peopleRank.user_id isEqualToString:@"10412"]) {
//        SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
//        liveRoomVC.target_id = peopleRank.user_id;
//        [self.navigationController pushViewController:liveRoomVC animated:YES];
    } else {
//        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
//        myLiveVC.user_id = [d valueForKey:kUserid];
//        myLiveVC.target_id = peopleRank.user_id;
//        
//        [self.navigationController pushViewController:myLiveVC animated:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

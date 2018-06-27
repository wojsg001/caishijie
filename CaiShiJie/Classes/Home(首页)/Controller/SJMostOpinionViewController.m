//
//  SJMostOpinionViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMostOpinionViewController.h"
#import "SJRecommendLiveCell.h"
#import "SJhttptool.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "SJLiveRoomModel.h"
#import "SJMyLiveViewController.h"
#import "SJNewLiveRoomViewController.h"

@interface SJMostOpinionViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJMostOpinionViewController

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
    
    self.view.backgroundColor = RGB(245, 245, 248);
    // 设置表格状态
    [self setUpTableView];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    // 加载今日热门数据
    [self loadMostOpinionLiveData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadMostOpinionLiveData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreMostOpinionLiveData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:@"SJRecommendLiveCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SJRecommendLiveCell"];
}

#pragma mark - 加载新数据
- (void)loadMostOpinionLiveData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/live",HOST];
    NSDictionary *dic = @{@"type":@"2",@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJLiveRoomModel objectArrayWithKeyValuesArray:respose[@"data"][@"live"]];
            
            if (tmpArr.count)
            {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}
#pragma mark - 加载更多数据
- (void)loadMoreMostOpinionLiveData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/live",HOST];
    NSDictionary *dic = @{@"type":@"2",@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJLiveRoomModel objectArrayWithKeyValuesArray:respose[@"data"][@"live"]];
            
            if (tmpArr.count)
            {
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJRecommendLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJRecommendLiveCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.dataArray.count)
    {
        if (indexPath.row == self.dataArray.count - 1)
        {
            cell.lineWidth.constant = SJScreenW - 20;
        }
        else
        {
            cell.lineWidth.constant = SJScreenW - 20 - 65;
        }
        
        cell.index = 102;
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}
// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 4.5, SJScreenW - 20, 0.5)];
    lineView.backgroundColor = RGB(227, 227, 227);
    [view addSubview:lineView];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJLiveRoomModel *model = self.dataArray[indexPath.row];
    if ([model.user_id isEqualToString:@"10412"]) {
        SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
        liveRoomVC.target_id = model.user_id;
        [self.navigationController pushViewController:liveRoomVC animated:YES];
    } else {
//        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
//        myLiveVC.user_id = [d valueForKey:kUserid];
//        myLiveVC.target_id = model.user_id;
//        //myLiveVC.live_id = hotLive.live_id;
//        [self.navigationController pushViewController:myLiveVC animated:YES];
    }
}

@end

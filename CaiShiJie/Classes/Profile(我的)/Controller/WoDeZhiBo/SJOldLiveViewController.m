//
//  SJOldLiveViewController.m
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJOldLiveViewController.h"
#import "SJhttptool.h"
#import "SJOldModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJMyLiveViewController.h"
#import "SJHistoryCell.h"
#import "SJHistoryTopCell.h"
#import "SJHistoryDownCell.h"

@interface SJOldLiveViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger i;
    NSNumber *num;
    NSMutableArray *array;
    NSMutableArray *modelarray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SJOldLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    modelarray =[NSMutableArray array];
    [self setUpTableView];
    [self loadmore];
    
    // 添加上拉刷新
    [self.tableView addFooterWithTarget:self action:@selector(loadmore)];
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示导航栏
    self.navigationController.navigationBarHidden = NO;
}

-(void)loadmore
{
    i = i+1;
    num =[NSNumber numberWithInteger:i];
    NSString *url =[NSString stringWithFormat:@"%@/mobile/live/history",HOST];
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:@10,@"pagesize",self.userid,@"userid",num,@"pageindex", nil];
    [SJhttptool GET:url paramers:paramers success:^(id respose) {
        // NSLog(@"%@",respose);
        NSDictionary *datadic = respose[@"data"];
        NSArray *history = datadic[@"history"];
        array=(NSMutableArray *)[SJOldModel objectArrayWithKeyValuesArray:history];
        
        [modelarray addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
    }];
}

- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // 注册表格
    UINib *nib1 = [UINib nibWithNibName:@"SJHistoryCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"SJHistoryCell"];
    
    UINib *nib2 = [UINib nibWithNibName:@"SJHistoryTopCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"SJHistoryTopCell"];
    
    UINib *nib3 = [UINib nibWithNibName:@"SJHistoryDownCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib3 forCellReuseIdentifier:@"SJHistoryDownCell"];
}

#pragma mark - UITableViewDataSource Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (modelarray.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (modelarray.count)
    {
        if (indexPath.row == 0)
        {
            SJHistoryTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHistoryTopCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        else if (indexPath.row == modelarray.count)
        {
            SJHistoryDownCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHistoryDownCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.oldLiveModel = modelarray[indexPath.row - 1];
            
            
            return cell;
        }
        else
        {
            SJHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHistoryCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.oldLiveModel = modelarray[indexPath.row - 1];
            
            return cell;
        }
    }

    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        SJOldModel *oldLive = modelarray[indexPath.row - 1];
        
        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        myLiveVC.user_id = [d valueForKey:kUserid];
        myLiveVC.target_id = oldLive.user_id;
        myLiveVC.live_id = oldLive.live_id;
        myLiveVC.isOldLive = YES;
        
        [self.navigationController pushViewController:myLiveVC animated:YES];
    }
}

@end

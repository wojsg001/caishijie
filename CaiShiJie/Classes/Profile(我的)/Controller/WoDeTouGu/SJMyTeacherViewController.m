//
//  SJMyTeacherViewController.m
//  CaiShiJie
//
//  Created by user on 18/3/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyTeacherViewController.h"
#import "SJMyTeacherCell.h"
#import "MJExtension.h"
#import "SJNetManager.h"
#import "SJMyTeacher.h"
#import "MJRefresh.h"
#import "SJMyLiveViewController.h"
#import "SJNewLiveRoomViewController.h"

@interface SJMyTeacherViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *teacherArr;

@end

@implementation SJMyTeacherViewController

- (NSMutableArray *)teacherArr
{
    if (_teacherArr == nil)
    {
        _teacherArr = [NSMutableArray array];
    }
    return _teacherArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    
    [self setUpTableView];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadMyTeacherListData)];
    
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreMyTeacherListData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
    
    // 加载我的老师列表
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMyTeacherListData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 加载我的老师列表
- (void)loadMyTeacherListData
{
    i = 1;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    [netManager requestMyTeacherListWithUserid:[d valueForKey:kUserid] andPageindex:[NSString stringWithFormat:@"%i",i] andPageSize:@"15" withSuccessBlock:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //NSLog(@"%@",dict);
        
        self.teacherArr = (NSMutableArray *)[SJMyTeacher objectArrayWithKeyValuesArray:dict[@"attention"]];
        
        [self.tableView headerEndRefreshing];
        [self.tableView reloadData];
        
        if (!self.teacherArr.count) {
            [SJNoDataView showNoDataViewToView:self.view];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}
#pragma mark - 加载更多老师信息
- (void)loadMoreMyTeacherListData
{
    i = i + 1;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    [netManager requestMyTeacherListWithUserid:[d valueForKey:kUserid] andPageindex:[NSString stringWithFormat:@"%i",i] andPageSize:@"10" withSuccessBlock:^(NSDictionary *dict) {
        
        NSArray *tmpArr = [SJMyTeacher objectArrayWithKeyValuesArray:dict[@"attention"]];
        
        [self.teacherArr addObjectsFromArray:tmpArr];
        
        [self.tableView footerEndRefreshing];
        [self.tableView reloadData];
        
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UINib *nib = [UINib nibWithNibName:@"SJMyTeacherCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teacherArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJMyTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.myTeacher = self.teacherArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyTeacher *myTeacher = self.teacherArr[indexPath.row];
    if ([myTeacher.user_id isEqualToString:@"10412"]) {
        SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
        liveRoomVC.target_id = myTeacher.user_id;
        [self.navigationController pushViewController:liveRoomVC animated:YES];
    } else {
//        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] initWithNibName:@"SJMyLiveViewController" bundle:[NSBundle mainBundle]];
//        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
//        myLiveVC.user_id = [d valueForKey:kUserid];
//        myLiveVC.target_id = myTeacher.user_id;
//        [self.navigationController pushViewController:myLiveVC animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadMyTeacherListData];
}

@end

//
//  SJHomeLiveViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJHomeLiveViewController.h"
#import "SJRecommendLiveCell.h"
#import "SJhttptool.h"
#import "SJLiveRoomModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJMyLiveViewController.h"
#import "SJHomeLiveHeadVIew.h"
#import "SJLiveRoomViewController.h"
#import "SJNewLiveRoomViewController.h"

@interface SJHomeLiveViewController ()<UITableViewDataSource, UITableViewDelegate, SJHomeLiveHeadVIewDelegate, SJNoWifiViewDelegate>
{
    NSArray *sectionArr;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *hotLiveArr;
@property (nonatomic, strong) NSMutableArray *fireLiveArr;
@property (nonatomic, strong) NSArray *imageModelArr;
@property (nonatomic, strong) SJHomeLiveHeadVIew *headView;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJHomeLiveViewController

- (SJHomeLiveHeadVIew *)headView {
    if (_headView == nil) {
        _headView = [[SJHomeLiveHeadVIew alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 95)];
        _headView.delegate = self;
    }
    return _headView;
}

- (NSMutableArray *)hotLiveArr {
    if (_hotLiveArr == nil) {
        _hotLiveArr = [[NSMutableArray alloc] init];
    }
    return _hotLiveArr;
}

- (NSMutableArray *)fireLiveArr {
    if (_fireLiveArr == nil) {
        _fireLiveArr = [[NSMutableArray alloc] init];
    }
    return _fireLiveArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    self.isNetwork = YES;
    // 设置表格状态
    [self setUpTableView];
    // section数组
    sectionArr = @[@"热点直播",@"火爆直播"];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadNewLiveData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewLiveData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpTableView {
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:@"SJRecommendLiveCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SJRecommendLiveCell"];
    
    self.tableView.tableHeaderView = self.headView;
}

#pragma mark - 加载推荐直播数据
- (void)loadNewLiveData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/home/live?hotSize=%i&fireSize=%i", HOST, 8, 8];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *hotArray = [SJLiveRoomModel objectArrayWithKeyValuesArray:respose[@"data"][@"LiveHot"]];
            if (hotArray.count) {
                [self.hotLiveArr removeAllObjects];
                [self.hotLiveArr addObjectsFromArray:hotArray];
            }
            NSArray *fireArray = [SJLiveRoomModel objectArrayWithKeyValuesArray:respose[@"data"][@"LiveFire"]];
            if (fireArray.count) {
                [self.fireLiveArr removeAllObjects];
                [self.fireLiveArr addObjectsFromArray:fireArray];
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // 热点直播
        return self.hotLiveArr.count;
    } else if (section == 1) {
        // 火爆直播
        return self.fireLiveArr.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJRecommendLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJRecommendLiveCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        // 热点直播
        if (self.hotLiveArr.count) {
            if (indexPath.row == self.hotLiveArr.count - 1) {
                cell.lineWidth.constant = SJScreenW - 20;
            } else {
                cell.lineWidth.constant = SJScreenW - 20 - 65;
            }
            
            cell.hotOrFireModel = self.hotLiveArr[indexPath.row];
        }
    } else {
        // 火爆直播
        if (self.fireLiveArr.count) {
            if (indexPath.row == self.fireLiveArr.count - 1) {
                cell.lineWidth.constant = SJScreenW - 20;
            } else {
                cell.lineWidth.constant = SJScreenW - 20 - 65;
            }
            
            cell.hotOrFireModel = self.fireLiveArr[indexPath.row];
        }
    }
    
    return cell;
}
// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

// section视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, SJScreenW - 20, 40)];
    sectionView.backgroundColor = [UIColor whiteColor];
    sectionView.layer.borderColor = RGB(227, 227, 227).CGColor;
    sectionView.layer.borderWidth = 0.5f;
    
    NSString *title = sectionArr[section];
    UILabel *titleLabel = [[UILabel alloc] init];
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    titleLabel.frame = (CGRect){{14, 12}, titleSize};
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    [sectionView addSubview:titleLabel];
    
    [view addSubview:sectionView];
    
    return view;
}
// section高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // 选择热点直播
        SJLiveRoomModel *model = self.hotLiveArr[indexPath.row];
        if ([model.user_id isEqualToString:@"10412"]) {
            SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
            liveRoomVC.target_id = model.user_id;
            [self.navigationController pushViewController:liveRoomVC animated:YES];
        } else {
            SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            myLiveVC.user_id = [d valueForKey:kUserid];
            myLiveVC.target_id = model.user_id;
            //myLiveVC.live_id = hotLive.live_id;
            [self.navigationController pushViewController:myLiveVC animated:YES];
        }
    } else {
        // 选择火爆直播
        SJLiveRoomModel *model = self.fireLiveArr[indexPath.row];
        if ([model.user_id isEqualToString:@"10412"]) {
            SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
            liveRoomVC.target_id = model.user_id;
            [self.navigationController pushViewController:liveRoomVC animated:YES];
        } else {
            SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            myLiveVC.user_id = [d valueForKey:kUserid];
            myLiveVC.target_id = model.user_id;
            [self.navigationController pushViewController:myLiveVC animated:YES];
        }
    }
}

#pragma mark - SJHomeLiveHeadVIewDelegate
- (void)homeLiveHeadVIew:(SJHomeLiveHeadVIew *)homeLiveHeadVIew didSelectedButton:(NSInteger)index {
    SJLiveRoomViewController *liveRoomVC = [[SJLiveRoomViewController alloc] init];
    
    switch (index) {
        case 101:
            liveRoomVC.selectedIndex = 0;
            break;
        case 102:
            liveRoomVC.selectedIndex = 1;
            break;
        case 103:
            liveRoomVC.selectedIndex = 2;
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:liveRoomVC animated:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadNewLiveData];
    }
}

@end

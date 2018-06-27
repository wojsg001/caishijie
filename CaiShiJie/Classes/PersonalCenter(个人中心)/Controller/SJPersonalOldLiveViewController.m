//
//  SJPersonalOldLiveViewController.m
//  CaiShiJie
//
//  Created by user on 18/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalOldLiveViewController.h"
#import "SJPersonalOldLiveHeadView.h"
#import <BlocksKit/NSArray+BlocksKit.h>
#import "SJHistoryCell.h"
#import "SJHistoryTopCell.h"
#import "SJHistoryDownCell.h"
#import "SJhttptool.h"
#import "SJOldModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJMyLiveViewController.h"
#import "SJNewLiveRoomViewController.h"

@interface SJPersonalOldLiveViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger i; // 分页
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJPersonalOldLiveHeadView *tableHeadView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isOpenLive;

@end

@implementation SJPersonalOldLiveViewController

- (SJPersonalOldLiveHeadView *)tableHeadView {
    if (!_tableHeadView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJPersonalCenterUI" owner:nil options:nil];
        _tableHeadView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJPersonalOldLiveHeadView class]];
        }];
        _tableHeadView.backgroundColor = [UIColor clearColor];
    }
    return _tableHeadView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    self.isOpenLive = NO;
    [self setupTableView];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadOldLiveData];
    // 添加下拉刷新和上拉加载
    [self.tableView addHeaderWithTarget:self action:@selector(loadOldLiveData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreOldLiveData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 注册表格
    UINib *nib1 = [UINib nibWithNibName:@"SJHistoryCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"SJHistoryCell"];
    UINib *nib2 = [UINib nibWithNibName:@"SJHistoryTopCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"SJHistoryTopCell"];
    UINib *nib3 = [UINib nibWithNibName:@"SJHistoryDownCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib3 forCellReuseIdentifier:@"SJHistoryDownCell"];
}

- (void)loadOldLiveData {
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/history",HOST];
    NSDictionary *paramers = @{@"userid":self.target_id,@"pagesize":@"10",@"pageindex":@(i)};
    [SJhttptool GET:urlStr paramers:paramers success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJOldModel objectArrayWithKeyValuesArray:respose[@"data"][@"history"]];
            if ([respose[@"data"][@"isOpenLive"] isEqual:@(0)]) {
                // 已开启直播
                self.isOpenLive = YES;
                NSDictionary *tmpDic = respose[@"data"][@"live"];
                if (NSDictionaryMatchAndCount(tmpDic)) {
                    self.tableHeadView.infoDic = tmpDic;
                }
            } else {
                // 尚未开启直播
                self.isOpenLive = NO;
            }
            if (tmpArray.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)loadMoreOldLiveData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/history",HOST];
    NSDictionary *paramers = @{@"userid":self.target_id,@"pagesize":@"10",@"pageindex":@(i)};
    [SJhttptool GET:urlStr paramers:paramers success:^(id respose) {
        //SJLog(@"%@", respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJOldModel objectArrayWithKeyValuesArray:respose[@"data"][@"history"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count) {
        if (indexPath.row == 0) {
            SJHistoryTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHistoryTopCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } else if (indexPath.row == self.dataArray.count) {
            SJHistoryDownCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHistoryDownCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.oldLiveModel = self.dataArray[indexPath.row - 1];
            
            return cell;
        } else {
            SJHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHistoryCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.oldLiveModel = self.dataArray[indexPath.row - 1];
            
            return cell;
        }
    }
    UITableViewCell *cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WS(weakSelf);
    self.tableHeadView.liveButtonClickBlock = ^() {
        if (weakSelf.isOpenLive) {
            if ([weakSelf.target_id isEqualToString:@"10412"]) {
                SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
                liveRoomVC.target_id = weakSelf.target_id;
                [weakSelf.navigationController pushViewController:liveRoomVC animated:YES];
            } else {
//                SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//                myLiveVC.user_id = [[NSUserDefaults standardUserDefaults] valueForKey:kUserid];
//                myLiveVC.target_id = weakSelf.target_id;
//                [weakSelf.navigationController pushViewController:myLiveVC animated:YES];
            }
        }
    };
    return self.tableHeadView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isOpenLive) {
        return 112;
    } else {
        return 72;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0) {
//        SJOldModel *model = self.dataArray[indexPath.row - 1];
//        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
//        myLiveVC.user_id = [d valueForKey:kUserid];
//        myLiveVC.target_id = model.user_id;
//        myLiveVC.live_id = model.live_id;
//        myLiveVC.isOldLive = YES;
//        
//        [self.navigationController pushViewController:myLiveVC animated:YES];
    }
}

@end

//
//  SJFindTeacherViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJFindTeacherViewController.h"
#import "SJMasterTeacherCell.h"
#import "SJFindTeacherSectionView.h"
#import "SJIntoTeacherCell.h"
#import "SJhttptool.h"
#import "SJMasterTeacherModel.h"
#import "MJExtension.h"
#import "SJCustom.h"
#import "MJRefresh.h"
#import "SJMyLiveViewController.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import "SJLoginViewController.h"
#import "SJNetManager.h"
#import "SJSearchTeacherViewController.h"
#import "SJNewLiveRoomViewController.h"
#import "SJPersonalCenterViewController.h"

@interface SJFindTeacherViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,SJMasterTeacherCellDelegate,SJNoWifiViewDelegate>
{
    int i;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 标题数组
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) NSArray *masterArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *attentionArray;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJFindTeacherViewController

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)attentionArray {
    if (_attentionArray == nil) {
        _attentionArray = [NSMutableArray array];
    }
    return _attentionArray;
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 42)];
        _searchBar.keyboardType = UIKeyboardAppearanceDefault;
        _searchBar.placeholder = @"搜索";
        _searchBar.delegate = self;
        _searchBar.barTintColor = RGB(245, 245, 248);
        _searchBar.layer.borderColor = RGB(245, 245, 248).CGColor;
        _searchBar.layer.borderWidth = 1;
        _searchBar.searchBarStyle = UISearchBarStyleDefault;
        _searchBar.barStyle = UIBarStyleDefault;
        UITextField *searchTextField = [[[_searchBar.subviews firstObject] subviews] lastObject];
        searchTextField.layer.borderColor = RGB(227, 227, 227).CGColor
        ;
        searchTextField.layer.borderWidth = 0.5f;
        searchTextField.layer.cornerRadius = 4.0f;
        searchTextField.layer.masksToBounds = YES; 
    }
    return _searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    self.isNetwork = YES;
    self.sectionArray = @[@{@"icon":@"index_account_icon1",@"title":@"精英投顾"},@{@"icon":@"index_account_icon2",@"title":@"入驻投顾"}];
    // 设置表格
    [self setUpTableView];
    // 加载精英投顾
    [self loadMasterTeacherData];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadInteTeacherData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadInteTeacherData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreInteTeacherData)];
    self.tableView.headerRefreshingText = @"正在刷新";
    self.tableView.footerRefreshingText = @"正在加载";
    // 接收通知
    [self receiveNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpTableView {
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJIntoTeacherCell" bundle:nil] forCellReuseIdentifier:@"SJIntoTeacherCell"];
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)loadMasterTeacherData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/teacher",HOST];
    NSDictionary *dic = @{@"pagesize":@"8"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = respose[@"data"][@"teacher"];
            if (tmpArr.count) {
                self.masterArray = [SJMasterTeacherModel objectArrayWithKeyValuesArray:tmpArr];
                NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:0];//刷新
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 加载入驻投顾数据
- (void)loadInteTeacherData {
    // 如果登录过，先获取当前用户关注过的投顾
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        [self loadMineAttentionData];
    }
    
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/recommend/fire",HOST];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%i",i],@"pageSize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJCustom objectArrayWithKeyValuesArray:respose[@"data"]];
            
            if (tmpArr.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
                
                [self.tableView reloadData];
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多入驻投顾数据
- (void)loadMoreInteTeacherData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/recommend/fire",HOST];
    NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%i",i],@"pageSize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //字典数组转化成模型数组
            NSArray *tmpArr =[SJCustom objectArrayWithKeyValuesArray:respose[@"data"]];
            
            if (tmpArr.count) {
                [self.dataArray addObjectsFromArray:tmpArr];
                
                [self.tableView reloadData];
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}
#pragma mark - 加载用户关注过的投顾
- (void)loadMineAttentionData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/focusteacher",HOST];
    SJToken *token = [SJToken sharedToken];
    
    [SJhttptool GET:urlStr paramers:token.keyValues success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            for (NSDictionary *dic in respose[@"data"]) {
                NSString *str = [NSString stringWithFormat:@"%@",dic[@"attention_user_id"]];
                [self.attentionArray addObject:str];
            }
  
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 接收通知
- (void)receiveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitLogin) name:KNotificationExitLogin object:nil];
}

- (void)loginSuccess {
    [self loadMineAttentionData];
}

- (void)exitLogin {
    [self.attentionArray removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.dataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SJMasterTeacherCell *cell = [SJMasterTeacherCell cellWithTableView:tableView];
        cell.delegate = self;

        if (!cell.array.count) {
            cell.array = self.masterArray;
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        SJIntoTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJIntoTeacherCell"];
        
        if (self.dataArray.count) {
            SJCustom *model = self.dataArray[indexPath.row];
            cell.model = model;
            if ([self.attentionArray containsObject:model.user_id]) {
                [cell.addAttentionBtn setImage:[UIImage imageNamed:@"index_account_icon_n"] forState:UIControlStateNormal];
                cell.addAttentionBtn.enabled = NO;
            } else {
                [cell.addAttentionBtn setImage:[UIImage imageNamed:@"index_account_icon_h"] forState:UIControlStateNormal];
                cell.addAttentionBtn.enabled = YES;
            }
            
            // 加关注
            cell.addAttentionBtn.tag = indexPath.row;
            [cell.addAttentionBtn addTarget:self action:@selector(clickAddAttentionButton:) forControlEvents:UIControlEventTouchUpInside];
        }

        return cell;
    }
    
    return [UITableViewCell new];
}
// 添加关注
- (void)clickAddAttentionButton:(UIButton *)button {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }

    SJCustom *model = self.dataArray[button.tag];
    SJToken *Token = [SJToken sharedToken];
    
    [[SJNetManager sharedNetManager] addAttentionWithToken:Token.token andUserid:Token.userid andTime:Token.time andTargetid:model.user_id withSuccessBlock:^(NSDictionary *dict) {
        
        if ([dict[@"status"] isEqual:@"1"])
        {
            [button setImage:[UIImage imageNamed:@"index_account_icon_n"] forState:UIControlStateNormal];
            button.enabled = NO;
            // 提示用户关注成功
            [MBProgressHUD showSuccess:@"关注成功"];
        }
        else
        {
            [MBHUDHelper showWarningWithText:dict[@"data"]];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 106;
    } else if (indexPath.section == 1) {
        return 65;
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.sectionArray[section];
    
    SJFindTeacherSectionView *sectionView = [[SJFindTeacherSectionView alloc] init];
    sectionView.frame = CGRectMake(0, 0, SJScreenW, 40);
    sectionView.iconView.image = [UIImage imageNamed:dic[@"icon"]];
    sectionView.titleLabel.text = dic[@"title"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 40)];
    [view addSubview:sectionView];
    
    if (section == 1) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 39, SJScreenW - 20, 0.5)];
        lineView.backgroundColor = RGB(227, 227, 227);
        
        [view addSubview:lineView];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        // 取消表格本身的选中状态
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        SJCustom *model = self.dataArray[indexPath.row];
        /*
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
        }*/
        SJPersonalCenterViewController *personalCenterVC = [[SJPersonalCenterViewController alloc] init];
        personalCenterVC.target_id = model.user_id;
        [self.navigationController pushViewController:personalCenterVC animated:YES];
    }
}

#pragma mark - SJMasterTeacherCellDelegate
- (void)masterTeacherCell:(SJMasterTeacherCell *)masterTeacherCell didSelectedwhichOne:(NSInteger)index {
    SJMasterTeacherModel *model = self.masterArray[index];
//    if ([model.user_id isEqualToString:@"10412"]) {
//        SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
//        liveRoomVC.target_id = model.user_id;
//        [self.navigationController pushViewController:liveRoomVC animated:YES];
//    } else {
//        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
//        myLiveVC.user_id = [d valueForKey:kUserid];
//        myLiveVC.target_id = model.user_id;
//        
//        [self.navigationController pushViewController:myLiveVC animated:YES];
//    }
    SJPersonalCenterViewController *personalCenterVC = [[SJPersonalCenterViewController alloc] init];
    personalCenterVC.target_id = model.user_id;
    [self.navigationController pushViewController:personalCenterVC animated:YES];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    SJSearchTeacherViewController *searchTeacherVC = [[SJSearchTeacherViewController alloc] init];
    searchTeacherVC.navigationItem.title = @"搜索投顾";
    [self.navigationController pushViewController:searchTeacherVC animated:YES];
    
    return NO;
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadMasterTeacherData];
        [self loadInteTeacherData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

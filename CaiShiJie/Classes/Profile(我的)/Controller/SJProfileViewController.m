//
//  SJProfileViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJProfileViewController.h"
#import "SJProfileCell.h"
#import "SJMyGoldCoinViewController.h"
#import "SJMyQuestionViewController.h"
#import "SJMyTeacherViewController.h"
#import "SJMyLiveViewController.h"
#import "SJUserQuestionViewController.h"
#import "SJSettingViewController.h"
#import "SJMyIncomeViewController.h"
#import "SJConsumptionViewController.h"
#import "SJUserReferenceViewController.h"
#import "SJTeacherReferenceViewController.h"
#import "SJProfileBlogArticleViewController.h"
#import "SJLoginViewController.h"
#import "SJRegisterViewController.h"
#import "SJUserInfo.h"
#import "SJProfileDefaultHeaderView.h"
#import "SJProfileHeaderView.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "SJNewLiveRoomViewController.h"
#import "SJMineMessageViewController.h"
#import "SJRTMPStreamViewController.h"
#import <NSArray+BlocksKit.h>
#import "UIScrollView+HeaderScaleImage.h"
#import "SJPersonsettingViewController.h"

@interface SJProfileViewController ()<UITableViewDataSource,UITableViewDelegate,SJProfileDefaultHeaderViewDelegate, SJProfileHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *userInfoDict;
@property (nonatomic, strong) SJProfileDefaultHeaderView *defaultHeaderView;
@property (nonatomic, strong) SJProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) NSArray *firstTeacherArray;
@property (nonatomic, strong) NSArray *firstuserArray;
@property (nonatomic, strong) NSArray *secondTeacherArray;
@property (nonatomic, strong) NSArray *seconduserArray;
@property (nonatomic, strong) NSArray *firstSectionArray;
@property (nonatomic, strong) NSArray *secondSectionArray;

@end

@implementation SJProfileViewController

- (SJProfileDefaultHeaderView *)defaultHeaderView {
    if (_defaultHeaderView == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJProfileUI" owner:nil options:nil];
        _defaultHeaderView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJProfileDefaultHeaderView class]];
        }];
        _defaultHeaderView.delegate = self;
    }
    return _defaultHeaderView;
}

- (SJProfileHeaderView *)profileHeaderView {
    if (_profileHeaderView == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJProfileUI" owner:nil options:nil];
        _profileHeaderView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJProfileHeaderView class]];
        }];
        _profileHeaderView.delegate = self;
    }
    return _profileHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 布局从0开始
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = RGB(245, 245, 248);
    // 设置表格属性
    [self setUpTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMQTTMessageData:) name:KNotificationMQTTHaveNewData object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // 初始化数据
    [self initData];
    // 设置用户信息
    self.tableView.yz_headerScaleImage = [UIImage imageNamed:@"nav_box"];
    [self setUpUserInfoView];
    // 更新用户信息
    [self updateUserInfo];
}

#pragma mark - 初始化数组
- (void)initData {
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]
        && ![[[NSUserDefaults standardUserDefaults] valueForKey:kUserName] isEqualToString:@"散户哨兵"]
        && ![[[NSUserDefaults standardUserDefaults] valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        _firstTeacherArray = @[/*@{@"image":@"mine_icon1.png",@"title":@"我的金币"},*/
                               @{@"image":@"mine_icon2.png",@"title":@"我的消息"},
                               @{@"image":@"mine_icon3.png",@"title":@"我的问股"},
                               @{@"image":@"mine_icon4.png",@"title":@"我的博文"},
                               @{@"image":@"mine_icon5.png",@"title":@"我的直播"}];
        _firstuserArray = @[/*@{@"image":@"mine_icon1.png",@"title":@"我的金币"},*/
                            @{@"image":@"mine_icon2.png",@"title":@"我的消息"},
                            @{@"image":@"mine_icon3.png",@"title":@"我的问股"},
                            @{@"image":@"mine_icon4.png",@"title":@"我的博文"}];
        
        _secondTeacherArray = @[/*@{@"image":@"mine_icon8.png",@"title":@"我的收入"},*/
                                /*@{@"image":@"mine_icon6.png",@"title":@"消费记录"},*/
                                @{@"image":@"mine_icon7.png",@"title":@"设置"}];
        _seconduserArray = @[@{@"image":@"mine_icon6.png",@"title":@"消费记录"},
                             @{@"image":@"mine_icon7.png",@"title":@"设置"}];
    } else {
        _firstTeacherArray = @[@{@"image":@"mine_icon2.png",@"title":@"我的消息"},
                               @{@"image":@"mine_icon3.png",@"title":@"我的问股"},
                               @{@"image":@"mine_icon4.png",@"title":@"我的博文"},
                               @{@"image":@"mine_icon5.png",@"title":@"我的直播"}];
        _firstuserArray = @[@{@"image":@"mine_icon2.png",@"title":@"我的消息"},
                            @{@"image":@"mine_icon3.png",@"title":@"我的问股"},
                            @{@"image":@"mine_icon4.png",@"title":@"我的博文"}];
        _secondTeacherArray = @[@{@"image":@"mine_icon7.png",@"title":@"设置"}];
        _seconduserArray = @[@{@"image":@"mine_icon7.png",@"title":@"设置"}];
    }
    
    self.firstSectionArray = _firstTeacherArray;
    self.secondSectionArray = _secondTeacherArray;
}

- (void)setUpTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH - HEIGHT_TABBAR) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SJProfileCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)setUpUserInfoView {
    // 如果成功登陆过
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 257)];
        self.profileHeaderView.frame = tableHeaderView.bounds;
        [tableHeaderView addSubview:self.profileHeaderView];
        self.tableView.tableHeaderView = tableHeaderView;
        
        self.userInfoDict = [SJUserDefaults objectForKey:kUserInfo];
        //SJLog(@"+++%@",self.userInfoDict);
        self.profileHeaderView.dict = self.userInfoDict;
        
        if ([self.userInfoDict[@"level"] isEqualToString:@"10"]) {
            // 如果是老师身份
            self.firstSectionArray = _firstTeacherArray;
            self.secondSectionArray = _secondTeacherArray;
            [self.tableView reloadData];
        } else {
            // 普通身份
            self.firstSectionArray = _firstuserArray;
            self.secondSectionArray = _seconduserArray;
            [self.tableView reloadData];
        }
    } else {
        // 没有登录时
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 207)];
        self.defaultHeaderView.frame = tableHeaderView.bounds;
        [tableHeaderView addSubview:self.defaultHeaderView];
        self.tableView.tableHeaderView = tableHeaderView;
        
        self.firstSectionArray = _firstTeacherArray;
        self.secondSectionArray = _secondTeacherArray;
        [self.tableView reloadData];
    }
}

- (void)updateUserInfo {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 没有登录过不更新
        return;
    }
    
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/getuserinfo",HOST];
    NSDictionary *dic = @{@"token":instance.token, @"userid":instance.userid, @"time":instance.time};
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"---%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            self.userInfoDict = respose[@"data"];
            self.profileHeaderView.dict = self.userInfoDict;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
    }];
}

#pragma mark - NSNotification
- (void)handleMQTTMessageData:(NSNotification *)n {
    [self.firstSectionArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *tmpDictionary = (NSDictionary *)obj;
        if ([tmpDictionary[@"title"] isEqualToString:@"我的消息"]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            *stop = YES;
        }
    }];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.firstSectionArray.count;
    } else if (section == 1) {
        return self.secondSectionArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.separatorInset = UIEdgeInsetsMake(0, 45, 0, 0);
    
    if (indexPath.section == 0) {
        NSDictionary *dict = self.firstSectionArray[indexPath.row];
        cell.imageIcon.image = [UIImage imageNamed:dict[@"image"]];
        cell.titleLabel.text = dict[@"title"];
        
        if ([dict[@"title"] isEqualToString:@"我的消息"] && (self.tabBarItem.badgeValue != nil && ![self.tabBarItem.badgeValue isEqualToString:@"0"])) {
            [cell setBadgeValueHidden:NO];
        } else {
            [cell setBadgeValueHidden:YES];
        }
    } else if (indexPath.section == 1) {
        NSDictionary *dict = self.secondSectionArray[indexPath.row];
        cell.imageIcon.image = [UIImage imageNamed:dict[@"image"]];
        cell.titleLabel.text = dict[@"title"];
        [cell setBadgeValueHidden:YES];
    }
 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 如果没有登录时
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    if (indexPath.section == 0) {
        if ([self.userInfoDict[@"level"] isEqualToString:@"10"]) {
            // 老师身份
            [self firstSectionTeacherDidSelectRowAtIndexPath:indexPath];
        } else {
            // 普通用户身份
            [self firstSectionUserDidSelectRowAtIndexPath:indexPath];
        }
    } else if (indexPath.section == 1) {
        if ([self.userInfoDict[@"level"] isEqualToString:@"10"]) {
            // 老师身份
            [self secondSectionTeacherDidSelectRowAtIndexPath:indexPath];
        } else {
            // 普通用户身份
            [self secondSectionUserDidSelectRowAtIndexPath:indexPath];
        }
    }
}
#pragma mark - 第一部分老师点击事件
- (void)firstSectionTeacherDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] && ![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        switch (indexPath.row) {
//            case 0:
//            {
//                SJMyGoldCoinViewController *myGoldCoinVC = [[SJMyGoldCoinViewController alloc] init];
//                myGoldCoinVC.title = @"我的金币";
//                myGoldCoinVC.goldCoinStr = self.userInfoDict[@"account"];
//                [self.navigationController pushViewController:myGoldCoinVC animated:YES];
//            }
//                break;
            case 0:
            {
                SJMineMessageViewController *messageVC = [[SJMineMessageViewController alloc] init];
                messageVC.navigationItem.title = @"消息";
                messageVC.target_id = self.userInfoDict[@"user_id"];
                [self.navigationController pushViewController:messageVC animated:YES];
            }
                break;
            case 1:
            {
                SJMyQuestionViewController *myQuestionVC = [[SJMyQuestionViewController alloc] init];
                [self.navigationController pushViewController:myQuestionVC animated:YES];
            }
                break;
            case 2:
            {
                SJProfileBlogArticleViewController *myBlogArticleVC = [[SJProfileBlogArticleViewController alloc] init];
                myBlogArticleVC.userid = [SJUserDefaults valueForKey:kUserid];
                myBlogArticleVC.title = @"我的博文";
                [self.navigationController pushViewController:myBlogArticleVC animated:YES];
            }
                break;
            case 3:
            {
                if ([[SJUserDefaults valueForKey:kUserid] isEqualToString:@"10412"]) {
                    SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
                    liveRoomVC.target_id = [SJUserDefaults valueForKey:kUserid];
                    [self.navigationController pushViewController:liveRoomVC animated:YES];
                } else {
                    SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
                    myLiveVC.user_id = [SJUserDefaults valueForKey:kUserid];
                    myLiveVC.target_id = [SJUserDefaults valueForKey:kUserid];
                    [self.navigationController pushViewController:myLiveVC animated:YES];
                }
            }
                break;
                
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
            {
                SJMineMessageViewController *messageVC = [[SJMineMessageViewController alloc] init];
                messageVC.navigationItem.title = @"消息";
                messageVC.target_id = self.userInfoDict[@"user_id"];
                [self.navigationController pushViewController:messageVC animated:YES];
            }
                break;
            case 1:
            {
                SJMyQuestionViewController *myQuestionVC = [[SJMyQuestionViewController alloc] init];
                [self.navigationController pushViewController:myQuestionVC animated:YES];
            }
                break;
            case 2:
            {
                SJProfileBlogArticleViewController *myBlogArticleVC = [[SJProfileBlogArticleViewController alloc] init];
                myBlogArticleVC.userid = [SJUserDefaults valueForKey:kUserid];
                myBlogArticleVC.title = @"我的博文";
                [self.navigationController pushViewController:myBlogArticleVC animated:YES];
                
            }
                break;
            case 3:
            {
                if ([[SJUserDefaults valueForKey:kUserid] isEqualToString:@"10412"]) {
                    SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
                    liveRoomVC.target_id = [SJUserDefaults valueForKey:kUserid];
                    [self.navigationController pushViewController:liveRoomVC animated:YES];
                } else {
                    SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
                    myLiveVC.user_id = [SJUserDefaults valueForKey:kUserid];
                    myLiveVC.target_id = [SJUserDefaults valueForKey:kUserid];
                    
                    [self.navigationController pushViewController:myLiveVC animated:YES];
                }
            }
                break;
                
            default:
                break;
        }
    }
}
#pragma mark - 第一部分用户点击事件
- (void)firstSectionUserDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] && ![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        switch (indexPath.row) {
//            case 0:
//            {
//                SJMyGoldCoinViewController *myGoldCoinVC = [[SJMyGoldCoinViewController alloc] init];
//                myGoldCoinVC.title = @"我的金币";
//                myGoldCoinVC.goldCoinStr = self.userInfoDict[@"account"];
//                [self.navigationController pushViewController:myGoldCoinVC animated:YES];
//            }
//                break;
            case 0:
            {
                SJMineMessageViewController *messageVC = [[SJMineMessageViewController alloc] init];
                messageVC.navigationItem.title = @"消息";
                messageVC.target_id = self.userInfoDict[@"user_id"];
                [self.navigationController pushViewController:messageVC animated:YES];
            }
                break;
            case 1:
            {
                SJUserQuestionViewController *userQuestionVC = [[SJUserQuestionViewController alloc] init];
                userQuestionVC.title = @"我的问股";
                [self.navigationController pushViewController:userQuestionVC animated:YES];
                
            }
                break;
            case 2:
            {
                SJProfileBlogArticleViewController *myBlogArticleVC = [[SJProfileBlogArticleViewController alloc] init];
                myBlogArticleVC.userid = [SJUserDefaults valueForKey:kUserid];
                myBlogArticleVC.title = @"我的博文";
                [self.navigationController pushViewController:myBlogArticleVC animated:YES];
                
            }
                break;
                
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
            {
                SJMineMessageViewController *messageVC = [[SJMineMessageViewController alloc] init];
                messageVC.navigationItem.title = @"消息";
                messageVC.target_id = self.userInfoDict[@"user_id"];
                [self.navigationController pushViewController:messageVC animated:YES];
            }
                break;
            case 1:
            {
                SJUserQuestionViewController *userQuestionVC = [[SJUserQuestionViewController alloc] init];
                userQuestionVC.title = @"我的问股";
                [self.navigationController pushViewController:userQuestionVC animated:YES];
            }
                break;
            case 2:
            {
                SJProfileBlogArticleViewController *myBlogArticleVC = [[SJProfileBlogArticleViewController alloc] init];
                myBlogArticleVC.userid = [SJUserDefaults valueForKey:kUserid];
                myBlogArticleVC.title = @"我的博文";
                [self.navigationController pushViewController:myBlogArticleVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}
#pragma mark - 第二部分老师点击事件
- (void)secondSectionTeacherDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] && ![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        switch (indexPath.row) {
//            case 0:
//            {
//                SJMyIncomeViewController *incomeVC = [[SJMyIncomeViewController alloc] init];
//                incomeVC.title = @"我的收入";
//                [self.navigationController pushViewController:incomeVC animated:YES];
//            }
//                break;
//            case 1:
//            {
//                SJConsumptionViewController *consumeVC = [[SJConsumptionViewController alloc] init];
//                [self.navigationController pushViewController:consumeVC animated:YES];
//            }
//                break;
            case 0:
            {
                SJSettingViewController *setVC = [[UIStoryboard storyboardWithName:@"SJSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"SJSettingViewController"];
                setVC.title = @"设置";
                [self.navigationController pushViewController:setVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    } else {
        SJSettingViewController *setVC = [[UIStoryboard storyboardWithName:@"SJSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"SJSettingViewController"];
        setVC.title = @"设置";
        [self.navigationController pushViewController:setVC animated:YES];
    }
}
#pragma mark - 第二部分用户点击事件
- (void)secondSectionUserDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] && ![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        switch (indexPath.row) {
//            case 0:
//            {
//                SJConsumptionViewController *consumeVC = [[SJConsumptionViewController alloc] init];
//                [self.navigationController pushViewController:consumeVC animated:YES];
//            }
//                break;
            case 0:
            {
                SJSettingViewController *setVC = [[UIStoryboard storyboardWithName:@"SJSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"SJSettingViewController"];
                setVC.title = @"设置";
                [self.navigationController pushViewController:setVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    } else {
        SJSettingViewController *setVC = [[UIStoryboard storyboardWithName:@"SJSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"SJSettingViewController"];
        setVC.title = @"设置";
        [self.navigationController pushViewController:setVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - SJProfileDefaultViewControllerDelegate 代理方法
- (void)didClickLoginButton {
    // 点击登录按钮时调用
    SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)didClickRegisterButton {
    // 点击注册按钮式调用
    SJRegisterViewController *registerVC = [[SJRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - SJProfileHeaderViewDelegate 
- (void)headerViewButtonClicked:(UIButton *)button {
    switch (button.tag) {
        case 11:// 我的内参
        {
            if ([self.userInfoDict[@"level"] isEqualToString:@"10"]) {
                // 老师身份
                SJTeacherReferenceViewController *teacherReferenceVC = [[SJTeacherReferenceViewController alloc] init];
                teacherReferenceVC.title = @"我的内参";
                teacherReferenceVC.user_id = self.userInfoDict[@"user_id"];
                [self.navigationController pushViewController:teacherReferenceVC animated:YES];
            } else {
                // 普通身份
                SJUserReferenceViewController *userReferenceVC = [[SJUserReferenceViewController alloc] init];
                userReferenceVC.title = @"我的内参";
                userReferenceVC.user_id = self.userInfoDict[@"user_id"];
                [self.navigationController pushViewController:userReferenceVC animated:YES];
            }
        }
            break;
        case 12:// 开启直播、我的投顾
        {
            if ([self.userInfoDict[@"level"] isEqualToString:@"10"]) {
                // 老师身份
                SJRTMPStreamViewController *rtmpVC = [[SJRTMPStreamViewController alloc] init];
                rtmpVC.targetid = self.userInfoDict[@"user_id"];
                [self presentViewController:rtmpVC animated:YES completion:nil];
            } else {
                // 普通身份
                SJMyTeacherViewController *myTeacherVC = [[SJMyTeacherViewController alloc] init];
                myTeacherVC.title = @"我的投顾";
                [self.navigationController pushViewController:myTeacherVC animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)headImgTapClicked{
    SJPersonsettingViewController *personvc =[[SJPersonsettingViewController alloc]initWithNibName:@"SJPersonsettingViewController" bundle:nil];
    personvc.title = @"个人设置";
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    [self.navigationController pushViewController:personvc animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

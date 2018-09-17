//
//  SJChatRoomViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJChatRoomViewController.h"
#import "DLTabedSlideView.h"
#import "DLFixedTabbarView.h"
#import "SJChatRoomPopularityListViewController.h"
#import "SJChatRoomFollowViewController.h"
#import "SDCycleScrollView.h"

@interface SJChatRoomViewController ()<DLTabedSlideViewDelegate>

@property (nonatomic, weak) SDCycleScrollView *cycleScrollView;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, strong) DLTabedSlideView *tabedSlideView;


@end

@implementation SJChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"回播";
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setUpHeadView];
    [self setUpSlideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpHeadView {
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SJScreenW, 170) imageURLStringsGroup:@[@"index-banner"]];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.autoScrollTimeInterval = 3.0;
    cycleScrollView.infiniteLoop = YES;
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    cycleScrollView.placeholderImage = [UIImage imageNamed:@"index-banner"];
    
    
    
    UIView *tmpHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 180)];
    self.headerView = tmpHeaderView;
    tmpHeaderView.backgroundColor = RGB(245, 245, 248);
    [tmpHeaderView addSubview:cycleScrollView];
    
    [self.view addSubview:self.headerView];
}

- (void)setUpSlideView {
    
    self.tabedSlideView = [[DLTabedSlideView alloc] initWithFrame:CGRectMake(0, self.headerView.frame.size.height , SJScreenW, self.view.bounds.size.height)];
    [self.tabedSlideView initWithDLTabedSlideViewType:DLTabedSlideViewCommon];
    self.tabedSlideView.delegate = self;
    [self.view addSubview:self.tabedSlideView];
    self.tabedSlideView.baseViewController = self;
    self.tabedSlideView.tabItemNormalColor = RGB(68, 68, 68);
    self.tabedSlideView.tabItemSelectedColor = RGB(247, 100, 8);
    self.tabedSlideView.tabbarTrackColor = RGB(247, 100, 8);
    self.tabedSlideView.tabbarBackgroundImage = [UIImage imageNamed:@"tabbarBk"];
    self.tabedSlideView.tabbarBottomSpacing = 0.0;
    
    DLTabedbarItem *item1 = [DLTabedbarItem itemWithTitle:@"人气排行" image:nil selectedImage:nil];
    DLTabedbarItem *item2 = [DLTabedbarItem itemWithTitle:@"我的关注" image:nil selectedImage:nil];
    self.tabedSlideView.tabbarItems = @[item1, item2];
    [self.tabedSlideView buildTabbar];
    
    self.tabedSlideView.selectedIndex = self.selectedIndex;
}

#pragma mark - DLTabedSlideViewDelegate
- (NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender {
    return 2;
}

- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index {
    switch (index) {
        case 0:
        {
            SJChatRoomPopularityListViewController *ctrl = [[SJChatRoomPopularityListViewController alloc] init];
            return ctrl;
        }
        case 1:
        {
            SJChatRoomFollowViewController *ctrl = [[SJChatRoomFollowViewController alloc] init];
            return ctrl;
        }
            
        default:
            return nil;
    }
}

@end

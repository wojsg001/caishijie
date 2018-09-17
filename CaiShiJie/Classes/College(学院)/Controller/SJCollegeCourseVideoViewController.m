//
//  SJCollegeCourseVideoViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCollegeCourseVideoViewController.h"
#import "DLTabedSlideView.h"
#import "DLFixedTabbarView.h"
#import "SJCourseViewcontroller.h"
#import "SDCycleScrollView.h"

#define kDefaultTabbarHeight 54

@interface SJCollegeCourseVideoViewController ()<DLTabedSlideViewDelegate>

@property (nonatomic, weak) SDCycleScrollView *cycleScrollView;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, strong) DLTabedSlideView *tabedSlideView;


@end

@implementation SJCollegeCourseVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, kDefaultTabbarHeight, SJScreenW, 170) imageURLStringsGroup:@[@"index-banner"]];
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
    
    self.tabedSlideView = [[DLTabedSlideView alloc] initWithFrame:CGRectMake(0, 0 , SJScreenW, self.view.bounds.size.height)];
    [self.tabedSlideView initWithDLTabedSlideViewType:DLTabedSlideViewCourseVideo];
     
    self.tabedSlideView.delegate = self;
    [self.view addSubview:self.tabedSlideView];
    self.tabedSlideView.baseViewController = self;
    self.tabedSlideView.tabItemNormalColor = RGB(68, 68, 68);
    self.tabedSlideView.tabItemSelectedColor = RGB(247, 100, 8);
    self.tabedSlideView.tabbarTrackColor = RGB(247, 100, 8);
    self.tabedSlideView.tabbarBackgroundImage = [UIImage imageNamed:@"tabbarBk"];
    self.tabedSlideView.tabbarBottomSpacing = 0.0;
    
    DLTabedbarItem *item1 = [DLTabedbarItem itemWithTitle:@"推荐" image:nil selectedImage:nil];
    DLTabedbarItem *item2 = [DLTabedbarItem itemWithTitle:@"涨停" image:nil selectedImage:nil];
    DLTabedbarItem *item3 = [DLTabedbarItem itemWithTitle:@"K线" image:nil selectedImage:nil];
    DLTabedbarItem *item4 = [DLTabedbarItem itemWithTitle:@"缠论" image:nil selectedImage:nil];
    DLTabedbarItem *item5 = [DLTabedbarItem itemWithTitle:@"指标" image:nil selectedImage:nil];
    
    self.tabedSlideView.tabbarItems = @[item1, item2, item3, item4, item5];
    [self.tabedSlideView buildTabbar];
    
    self.tabedSlideView.selectedIndex = self.selectedIndex;
}

#pragma mark - DLTabedSlideViewDelegate
- (NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender {
    return 5;
}

- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index {
    switch (index) {
        case 0:
        {
            SJCourseViewcontroller *ctrl = [[SJCourseViewcontroller alloc] init];
            return ctrl;
        }
        case 1:
        {
            SJCourseViewcontroller *ctrl = [[SJCourseViewcontroller alloc] init];
            return ctrl;
        }
        case 2:
        {
            SJCourseViewcontroller *ctrl = [[SJCourseViewcontroller alloc] init];
            return ctrl;
        }
        case 3:
        {
            SJCourseViewcontroller *ctrl = [[SJCourseViewcontroller alloc] init];
            return ctrl;
        }
        case 4:
        {
            SJCourseViewcontroller *ctrl = [[SJCourseViewcontroller alloc] init];
            return ctrl;
        }
            
        default:
            return nil;
    }
}

@end

//
//  SJTabBarController.m
//  CaiShiJie
//
//  Created by user on 15/12/21.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJTabBarController.h"
#import "SJTabBar.h"
#import "SJHomeRecommendViewController.h"
#import "SJProfileViewController.h"
#import "SJpageViewController.h"
#import "SJNavigationController.h"
#import "SJSchoolViewcontroller.h"
#import "SJPhoneVideoListViewController.h"

@interface SJTabBarController ()<SJTabBarDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, weak) SJTabBar *customTabBar;
@property (nonatomic, weak) SJPhoneVideoListViewController *videoListVC;

@end

@implementation SJTabBarController

- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

+ (void)initialize {
    UITabBar *tabBar = [UITabBar appearanceWhenContainedIn:self, nil];
    [tabBar setShadowImage:[UIImage new]];
    [tabBar setBackgroundImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加所有子控制器
    [self setUpAllChildViewController];
    // 自定义tabBar
    [self setUpTabBar];
    // KVO监控
    [self addObserver:self forKeyPath:@"selectedViewController" options:NSKeyValueObservingOptionNew context:nil];
}

//自定义的tabbar在iOS中重叠的情况.就是原本已经移除的UITabBarButton再次出现
-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    for (UIView *child in self.tabBar.subviews) {
        
        if ([child isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            [child removeFromSuperview];
            
        }
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    
    // 移除系统的tabBarButton
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButton removeFromSuperview];
        }
    }
    
    [super viewWillAppear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self.customTabBar setupSelectedWhichOneButton:self.selectedIndex];
}

- (void)setUpTabBar {
    SJTabBar *customTabBar = [[SJTabBar alloc] initWithFrame:self.tabBar.bounds];
    self.customTabBar = customTabBar;
    customTabBar.backgroundColor = [UIColor whiteColor];
    customTabBar.delegate = self;
    customTabBar.items = self.items;
    [self.tabBar addSubview:customTabBar];
}

#pragma mark - 添加所有的子控制器
- (void)setUpAllChildViewController {
    //首页
    SJHomeRecommendViewController *home = [[SJHomeRecommendViewController alloc] init];
    [self setUpOneChildViewController:home image:[UIImage imageNamed:@"table_bar_icon_live_n"] selectedImage:[UIImage imageWithOriginalName:@"table_bar_icon_live_h"] title:@"首页"];
    
    //自选股
    SJpageViewController *attention = [[SJpageViewController alloc] init];
    [self setUpOneChildViewController:attention image:[UIImage imageNamed:@"table_bar_icon_index_n"] selectedImage:[UIImage imageWithOriginalName:@"table_bar_icon_index_h"] title:@"自选股"];

    //直播
    SJPhoneVideoListViewController *videoListVC = [[SJPhoneVideoListViewController alloc] init];
    [self setUpOneChildViewController:videoListVC image:[UIImage imageNamed:@"nav_icon_n"] selectedImage:[UIImage imageWithOriginalName:@"nav_icon_h"] title:@"直播"];
    _videoListVC = videoListVC;

    //股民学院
    SJSchoolViewcontroller *share = [[SJSchoolViewcontroller alloc] init];
    [self setUpOneChildViewController:share image:[UIImage imageNamed:@"table_bar_icon_share_n"] selectedImage:[UIImage imageWithOriginalName:@"table_bar_icon_share_h"] title:@"股民学院"];

    //我的
    SJProfileViewController *profile = [[SJProfileViewController alloc] init];
    [self setUpOneChildViewController:profile image:[UIImage imageNamed:@"table_bar_icon_mine_n"] selectedImage:[UIImage imageWithOriginalName:@"table_bar_icon_mine_h"] title:@"我的"];
}

#pragma mark - 添加一个子控制器
- (void)setUpOneChildViewController:(UIViewController *)vc image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title {
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selectedImage;
    
    // 保存tabBarItem模型到数组
    [self.items addObject:vc.tabBarItem];
    
    SJNavigationController *nav = [[SJNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

#pragma mark - SJTabBarDelegate
- (void)tabBar:(SJTabBar *)tabBar didClickButton:(NSInteger)index {
    if (index == 2 && self.selectedIndex == index) {
        [_videoListVC refresh];
    }
    self.selectedIndex = index;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

//
//  SJNavigationController.m
//  CaiShiJie
//
//  Created by user on 15/12/21.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJNavigationController.h"
#import "SJTabBar.h"

@interface SJNavigationController ()<UINavigationControllerDelegate>

@end

@implementation SJNavigationController

+ (void)initialize {
    if (self == [SJNavigationController class]) {
        // 设置导航条的标题
        [self setUpNavBarTitle];
        // 设置导航条的按钮
        [self setUpNavBarButton];
    }
}

+ (void)setUpNavBarButton {
    // 设置导航栏左侧或者右侧BarButtonItem的主题
    UIBarButtonItem *item = [UIBarButtonItem appearanceWhenContainedIn:[SJNavigationController class], nil];
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
}

// 设置导航条的标题
+ (void)setUpNavBarTitle {
    // 设置导航栏主题
    UINavigationBar *naviBar = [UINavigationBar appearanceWhenContainedIn:[SJNavigationController class], nil];
    naviBar.tintColor = [UIColor whiteColor];//设置返回箭头的颜色
    [naviBar setBackgroundImage:[UIImage imageNamed:@"nav_box"] forBarMetrics:UIBarMetricsDefault];
    // 设置导航栏中间标题文字的字体、颜色
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    [naviBar setTitleTextAttributes:attrs];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WS(weakSelf);
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = (id)weakSelf;
        self.delegate = weakSelf;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count) {
        // 不是根控制器
        viewController.hidesBottomBarWhenPushed = YES;
        // 添加返回按钮
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"live_up_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtn)];
        viewController.navigationItem.leftBarButtonItem = leftBtn;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == [self.childViewControllers firstObject]) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    } else {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
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

// 点击返回按钮式调用
- (void)backBtn {
    [self popViewControllerAnimated:YES];
}

@end

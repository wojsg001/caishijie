//
//  SJRankingsViewController.m
//  CaiShiJie
//
//  Created by user on 16/1/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRankingsViewController.h"
#import "SJRankHeadView.h"
#import "SJQuestionRankViewController.h"
#import "SJGiftRankViewController.h"
#import "SJPeopleRankViewController.h"
#import "SJLogRankViewController.h"

@interface SJRankingsViewController ()<SJRankHeadViewDelegate, SJNoWifiViewDelegate>

@property (nonatomic, strong) SJRankHeadView *headView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, assign) BOOL isNetwork;
@property (nonatomic, strong) SJQuestionRankViewController *firstVC;

@end

@implementation SJRankingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = RGB(245, 245, 248);
    self.isNetwork = YES;

    [self setupChildViews];
    [self addChildViewControllers];

    // 默认,第一个视图
    _firstVC = [self.childViewControllers firstObject];
    WS(weakSelf);
    _firstVC.showNoWifiViewBlock = ^() {
        weakSelf.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:weakSelf.view delegate:weakSelf];
    };
    _firstVC.view.frame = _contentView.bounds;
    [self.contentView addSubview:_firstVC.view];
    self.currentVC = _firstVC;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupChildViews {
    _headView = [[SJRankHeadView alloc] init];
    _headView.delegate = self;
    [self.view addSubview:_headView];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    WS(weakSelf);
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(SJScreenW/4);
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.equalTo(weakSelf.headView.mas_bottom).offset(0);
    }];
}

- (void)addChildViewControllers {
    SJQuestionRankViewController *questionRankVC = [[SJQuestionRankViewController alloc] init];
    SJGiftRankViewController *giftRankVC = [[SJGiftRankViewController alloc] init];
    SJPeopleRankViewController *peopleRankVC = [[SJPeopleRankViewController alloc] init];
    SJLogRankViewController *logRankVC = [[SJLogRankViewController alloc] init];
    
    [self addChildViewController:questionRankVC];
    [self addChildViewController:giftRankVC];
    [self addChildViewController:peopleRankVC];
    [self addChildViewController:logRankVC];
}

#pragma mark - SJRankHeadViewDelegate
- (void)rankHeadView:(SJRankHeadView *)rankHeadView clickButtonDown:(NSInteger)index {
    UIViewController *viewController = [self.childViewControllers objectAtIndex:index - 101];
    if (self.currentVC == viewController) {
        return;
    }
    
    // 切换控制器
    viewController.view.frame = _contentView.bounds;
    [self replaceController:self.currentVC newController:viewController];
}

//  切换各个标签内容
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController {
    /**
     *			着重介绍一下它
     *  transitionFromViewController:toViewController:duration:options:animations:completion:
     *  fromViewController	    当前显示在父视图控制器中的子视图控制器
     *  toViewController		将要显示的姿势图控制器
     *  duration				动画时间(这个属性,old friend 了 O(∩_∩)O)
     *  options				    动画效果(渐变,从下往上等等,具体查看API)
     *  animations			    转换过程中得动画
     *  completion			    转换完成
     */
    [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            self.currentVC = newController;
        } else {
            self.currentVC = oldController;
        }
    }];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        [self.firstVC loadQuestionRankData];
    }
}

@end

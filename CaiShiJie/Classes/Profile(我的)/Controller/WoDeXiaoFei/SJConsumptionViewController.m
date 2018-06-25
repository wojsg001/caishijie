//
//  SJConsumptionViewController.m
//  CaiShiJie
//
//  Created by user on 18/7/28.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJConsumptionViewController.h"
#import "DLScrollTabbarView.h"
#import "DLLRUCache.h"
#import "DLCustomSlideView.h"
#import "SJWaitPayViewController.h"
#import "SJPrepaidViewController.h"

@interface SJConsumptionViewController ()<DLCustomSlideViewDelegate>

@property (nonatomic, strong) DLCustomSlideView *slideView;

@end

@implementation SJConsumptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"消费记录";
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setUpSlideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)setUpSlideView
{
    DLLRUCache *cache = [[DLLRUCache alloc] initWithCount:4];
    DLScrollTabbarView *tabbar = [[DLScrollTabbarView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 45)];
    tabbar.tabItemNormalColor = RGB(68, 68, 68);
    tabbar.tabItemSelectedColor = RGB(217, 67, 50);
    tabbar.trackColor = RGB(217, 67, 50);
    tabbar.tabItemNormalFontSize = 16.0f;
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 45)];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = RGB(227, 227, 227);
    [backgroundView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(backgroundView);
        make.height.mas_equalTo(0.5);
    }];
    tabbar.backgroundView = backgroundView;
    
    DLScrollTabbarItem *item1 = [DLScrollTabbarItem itemWithTitle:@"全部" width:SJScreenW/4];
    DLScrollTabbarItem *item2 = [DLScrollTabbarItem itemWithTitle:@"支付成功" width:SJScreenW/4];
    DLScrollTabbarItem *item3 = [DLScrollTabbarItem itemWithTitle:@"待支付" width:SJScreenW/4];
    DLScrollTabbarItem *item4 = [DLScrollTabbarItem itemWithTitle:@"支付失败" width:SJScreenW/4];
    
    tabbar.tabbarItems = @[item1, item2, item3, item4];
    
    self.slideView = [[DLCustomSlideView alloc] initWithFrame:self.view.bounds];
    self.slideView.delegate = self;
    [self.view addSubview:self.slideView];
    self.slideView.tabbar = tabbar;
    self.slideView.cache = cache;
    self.slideView.baseViewController = self;
    [self.slideView setup];
    self.slideView.selectedIndex = 0;
    self.slideView.tabbarBottomSpacing = 0.0f;
}

#pragma mark - DLTabedSlideViewDelegate
- (NSInteger)numberOfTabsInDLCustomSlideView:(DLCustomSlideView *)sender{
    return 4;
}

- (UIViewController *)DLCustomSlideView:(DLCustomSlideView *)sender controllerAt:(NSInteger)index{
    switch (index) {
        case 0:
        {
            SJPrepaidViewController *ctrl = [[SJPrepaidViewController alloc] init];
            ctrl.status = @"0";
            return ctrl;
        }
        case 1:
        {
            SJPrepaidViewController *ctrl = [[SJPrepaidViewController alloc] init];
            ctrl.status = @"4";
            return ctrl;
        }
        case 2:
        {
            SJWaitPayViewController *ctrl = [[SJWaitPayViewController alloc] init];
            return ctrl;
        }
        case 3:
        {
            SJPrepaidViewController *ctrl = [[SJPrepaidViewController alloc] init];
            ctrl.status = @"2";
            return ctrl;
        }
            
        default:
            return nil;
    }
}

@end

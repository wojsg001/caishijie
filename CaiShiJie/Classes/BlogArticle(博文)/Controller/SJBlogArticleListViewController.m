//
//  SJBlogArticleListViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBlogArticleListViewController.h"
#import "DLScrollTabbarView.h"
#import "DLLRUCache.h"
#import "DLCustomSlideView.h"
#import "SJBlogZhuanLanTwoViewController.h"
#import "SJZaoWanPingViewController.h"
#import "SJZhuaNiuGuViewController.h"
#import "SJShaiZhanJiViewController.h"
#import "SJBlogZhuanTiViewController.h"
#import "SJBlogRankViewController.h"

@interface SJBlogArticleListViewController ()<DLCustomSlideViewDelegate>

@property (nonatomic, strong) DLCustomSlideView *slideView;

@end

@implementation SJBlogArticleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"股评列表";
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setUpSlideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpSlideView {
    DLLRUCache *cache = [[DLLRUCache alloc] initWithCount:6];
    DLScrollTabbarView *tabbar = [[DLScrollTabbarView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 35)];
    tabbar.tabItemNormalColor = RGB(68, 68, 68);
    tabbar.tabItemSelectedColor = RGB(247, 100, 8);
    tabbar.trackColor = RGB(247, 100, 8);
    tabbar.tabItemNormalFontSize = 14.0f;
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 35)];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = RGB(227, 227, 227);
    [backgroundView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(backgroundView);
        make.height.mas_equalTo(0.5);
    }];
    tabbar.backgroundView = backgroundView;

    DLScrollTabbarItem *item1 = [DLScrollTabbarItem itemWithTitle:@"早晚评" width:SJScreenW/(67*3+52*3)*67];
    DLScrollTabbarItem *item2 = [DLScrollTabbarItem itemWithTitle:@"抓牛股" width:SJScreenW/(67*3+52*3)*67];
    DLScrollTabbarItem *item3 = [DLScrollTabbarItem itemWithTitle:@"晒战绩" width:SJScreenW/(67*3+52*3)*67];
    DLScrollTabbarItem *item4 = [DLScrollTabbarItem itemWithTitle:@"专栏" width:SJScreenW/(67*3+52*3)*52];
    DLScrollTabbarItem *item5 = [DLScrollTabbarItem itemWithTitle:@"专题" width:SJScreenW/(67*3+52*3)*52];
    DLScrollTabbarItem *item6 = [DLScrollTabbarItem itemWithTitle:@"排行" width:SJScreenW/(67*3+52*3)*52];
    
    tabbar.tabbarItems = @[item1, item2, item3, item4, item5, item6];
    
    self.slideView = [[DLCustomSlideView alloc] initWithFrame:self.view.bounds];
    self.slideView.delegate = self;
    [self.view addSubview:self.slideView];
    self.slideView.tabbar = tabbar;
    self.slideView.cache = cache;
    self.slideView.baseViewController = self;
    [self.slideView setup];
    self.slideView.selectedIndex = self.selectedIndex;
    self.slideView.tabbarBottomSpacing = 0.0f;
}

#pragma mark - DLTabedSlideViewDelegate
- (NSInteger)numberOfTabsInDLCustomSlideView:(DLCustomSlideView *)sender{
    return 6;
}

- (UIViewController *)DLCustomSlideView:(DLCustomSlideView *)sender controllerAt:(NSInteger)index{
    switch (index) {
        case 0:
        {
            SJZaoWanPingViewController *ctrl = [[SJZaoWanPingViewController alloc] init];
            return ctrl;
        }
        case 1:
        {
            SJZhuaNiuGuViewController *ctrl = [[SJZhuaNiuGuViewController alloc] init];
            return ctrl;
        }
        case 2:
        {
            SJShaiZhanJiViewController *ctrl = [[SJShaiZhanJiViewController alloc] init];
            return ctrl;
        }
        case 3:
        {
            SJBlogZhuanLanTwoViewController *ctrl = [[SJBlogZhuanLanTwoViewController alloc] init];
            return ctrl;
        }
        case 4:
        {
            SJBlogZhuanTiViewController *ctrl = [[SJBlogZhuanTiViewController alloc] init];
            return ctrl;
        }
        case 5:
        {
            SJBlogRankViewController *ctrl = [[SJBlogRankViewController alloc] init];
            return ctrl;
        }
            
        default:
            return nil;
    }
}

@end

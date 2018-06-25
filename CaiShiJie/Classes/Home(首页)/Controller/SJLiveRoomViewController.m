//
//  SJLiveRoomViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveRoomViewController.h"
#import "DLTabedSlideView.h"
#import "DLFixedTabbarView.h"
#import "SJTodayHotViewController.h"
#import "SJMostOpinionViewController.h"
#import "SJMostInteractionViewController.h"

@interface SJLiveRoomViewController ()<DLTabedSlideViewDelegate>

@property (nonatomic, strong) DLTabedSlideView *tabedSlideView;

@end

@implementation SJLiveRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"直播间";
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setUpSlideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpSlideView {
    self.tabedSlideView = [[DLTabedSlideView alloc] initWithFrame:self.view.bounds];
    self.tabedSlideView.delegate = self;
    [self.view addSubview:self.tabedSlideView];
    self.tabedSlideView.baseViewController = self;
    self.tabedSlideView.tabItemNormalColor = RGB(68, 68, 68);
    self.tabedSlideView.tabItemSelectedColor = RGB(247, 100, 8);
    self.tabedSlideView.tabbarTrackColor = RGB(247, 100, 8);
    self.tabedSlideView.tabbarBackgroundImage = [UIImage imageNamed:@"tabbarBk"];
    self.tabedSlideView.tabbarBottomSpacing = 0.0;
    
    DLTabedbarItem *item1 = [DLTabedbarItem itemWithTitle:@"今日热门" image:nil selectedImage:nil];
    DLTabedbarItem *item2 = [DLTabedbarItem itemWithTitle:@"观点最多" image:nil selectedImage:nil];
    DLTabedbarItem *item3 = [DLTabedbarItem itemWithTitle:@"互动最多" image:nil selectedImage:nil];
    self.tabedSlideView.tabbarItems = @[item1, item2, item3];
    [self.tabedSlideView buildTabbar];
    
    self.tabedSlideView.selectedIndex = self.selectedIndex;
}

#pragma mark - DLTabedSlideViewDelegate
- (NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender {
    return 3;
}

- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index {
    switch (index) {
        case 0:
        {
            SJTodayHotViewController *ctrl = [[SJTodayHotViewController alloc] init];
            return ctrl;
        }
        case 1:
        {
            SJMostOpinionViewController *ctrl = [[SJMostOpinionViewController alloc] init];
            return ctrl;
        }
        case 2:
        {
            SJMostInteractionViewController *ctrl = [[SJMostInteractionViewController alloc] init];
            return ctrl;
        }
            
        default:
            return nil;
    }
}

@end

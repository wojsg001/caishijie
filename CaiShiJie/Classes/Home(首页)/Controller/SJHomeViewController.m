//
//  SJHomeViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHomeViewController.h"
#import "SlideHeadView.h"
#import "SJHomeRecommendViewController.h"
#import "SJHomeLiveViewController.h"
#import "SJFindTeacherViewController.h"
#import "SJRankingsViewController.h"
#import "SJHomeQuestionViewController.h"

@interface SJHomeViewController ()

@property (nonatomic, strong) SlideHeadView *slideVC;

@end

@implementation SJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"财视界";
    self.view.backgroundColor = RGB(255, 255, 255);
    // 设置SlideHeadView
    [self setUpSlideHeadView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setUpSlideHeadView {
    // 初始化SlideHeadView，并加进view
    _slideVC = [[SlideHeadView alloc]init];
    [self.view addSubview:_slideVC];
    
    // 初始化子控制器
    SJHomeRecommendViewController *recommendLiveVC = [[SJHomeRecommendViewController alloc] init];
    SJHomeLiveViewController *recommendLogVC = [[SJHomeLiveViewController alloc] init];
    SJFindTeacherViewController *findTeacherVC = [[SJFindTeacherViewController alloc] init];
    SJRankingsViewController *rankVC = [[SJRankingsViewController alloc] init];
    SJHomeQuestionViewController *questionVC = [[SJHomeQuestionViewController alloc] init];
    
    NSArray *titleArr = @[@"推荐",@"直播",@"找投顾",@"问答",@"排行榜"];
    _slideVC.titlesArr = titleArr;
    
    [_slideVC addChildViewController:recommendLiveVC title:titleArr[0]];
    [_slideVC addChildViewController:recommendLogVC title:titleArr[1]];
    [_slideVC addChildViewController:findTeacherVC title:titleArr[2]];
    [_slideVC addChildViewController:questionVC title:titleArr[3]];
    [_slideVC addChildViewController:rankVC title:titleArr[4]];
    
    // 最后再调用setSlideHeadView完成
    [_slideVC setSlideHeadView];
    
    _slideVC.selectTitleBtnBlock = ^(NSInteger index) {
        switch (index) {
            case 0:
                [recommendLiveVC refreshNetwork];
                break;
            case 1:
                [recommendLogVC refreshNetwork];
                break;
            case 2:
                [findTeacherVC refreshNetwork];
                break;
            case 3:
                [questionVC refreshNetwork];
                break;
            case 4:
                [rankVC refreshNetwork];
                break;
                
            default:
                break;
        }
    };
}

@end

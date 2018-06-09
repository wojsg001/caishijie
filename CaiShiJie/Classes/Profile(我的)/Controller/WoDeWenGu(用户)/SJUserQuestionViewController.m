//
//  SJUserQuestionViewController.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJUserQuestionViewController.h"
#import "SJUserAnswerViewController.h"
#import "SJUserNoAnswerViewController.h"

@interface SJUserQuestionViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) SJUserAnswerViewController *answerVC;
@property (nonatomic, strong) SJUserNoAnswerViewController *noAnswerVC;
@property (nonatomic, strong) UIViewController *currentVC;

@end

@implementation SJUserQuestionViewController

- (SJUserAnswerViewController *)answerVC {
    if (!_answerVC) {
        _answerVC = [[SJUserAnswerViewController alloc] init];
        _answerVC.view.frame = CGRectMake(0, 45, self.view.width, self.view.height - 45);
    }
    return _answerVC;
}

- (SJUserNoAnswerViewController *)noAnswerVC {
    if (!_noAnswerVC) {
        _noAnswerVC = [[SJUserNoAnswerViewController alloc] init];
        _noAnswerVC.view.frame = CGRectMake(0, 45, self.view.width, self.view.height - 45);
    }
    return _noAnswerVC;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的咨询记录";
    // 设置分段控件
    [self setUpSegmentedControl];
    
    [self.view addSubview:self.answerVC.view];
    [self addChildViewController:self.answerVC];
    self.currentVC = self.answerVC;
}

// 设置分段选择控件
- (void)setUpSegmentedControl
{
    // 设置边框
    _segmentedControl.layer.borderColor = RGB(247, 100, 8).CGColor;
    _segmentedControl.layer.borderWidth = 1.0f;
    // 设置圆角
    _segmentedControl.layer.cornerRadius = 5.0;
    _segmentedControl.layer.masksToBounds = YES;
    // 背景色
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    // 选中色
    _segmentedControl.tintColor = RGB(247, 100, 8);
    // 设置默认状态字体大小和颜色
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    attributes[NSForegroundColorAttributeName] = RGB(247, 100, 8);
    [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    // 设置选择状态时的大小和颜色
    attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateSelected];
    
    // 设置在点击后是否恢复原样
    _segmentedControl.momentary = NO;
    // 默认选中第0个
    _segmentedControl.selectedSegmentIndex = 0;
    
    [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentAction:(UISegmentedControl *)seg
{
    switch (seg.selectedSegmentIndex) {
        case 0:
        {
            [self replaceController:self.currentVC newController:self.answerVC];
        }
            break;
        case 1:
        {
            [self replaceController:self.currentVC newController:self.noAnswerVC];
        }
            break;
            
        default:
            break;
    }
}

//  切换各个标签内容
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController {
    WS(weakSelf);
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:weakSelf];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            weakSelf.currentVC = newController;
        } else {
            weakSelf.currentVC = oldController;
        }
    }];
}

@end

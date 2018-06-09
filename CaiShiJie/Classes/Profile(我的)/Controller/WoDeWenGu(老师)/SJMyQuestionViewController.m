//
//  SJMyQuestionViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJMyQuestionViewController.h"
#import "SJTeacherQuestionViewController.h"
#import "SJTeacherAnswerViewController.h"

@interface SJMyQuestionViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) SJTeacherQuestionViewController *questionVC;
@property (nonatomic, strong) SJTeacherAnswerViewController *answerVC;
@property (nonatomic, strong) UIViewController *currentVC;

@end

@implementation SJMyQuestionViewController

- (SJTeacherQuestionViewController *)questionVC {
    if (!_questionVC) {
        _questionVC = [[SJTeacherQuestionViewController alloc] init];
        _questionVC.view.frame = CGRectMake(0, 45, self.view.width, self.view.height - 45);
    }
    return _questionVC;
}

- (SJTeacherAnswerViewController *)answerVC {
    if (!_answerVC) {
        _answerVC = [[SJTeacherAnswerViewController alloc] init];
        _answerVC.view.frame = CGRectMake(0, 45, self.view.width, self.view.height - 45);
    }
    return _answerVC;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的咨询记录";
    [self addChildViewController:self.questionVC];
    [self.view addSubview:self.questionVC.view];
    self.currentVC = self.questionVC;
    
    [self setUpSegmentedControl];
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
            [self replaceController:self.currentVC newController:self.questionVC];
            break;
        case 1:
            [self replaceController:self.currentVC newController:self.answerVC];
            break;
            
        default:
            break;
    }
}

//  切换各个标签内容
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    /**
     *			着重介绍一下它
     *  transitionFromViewController:toViewController:duration:options:animations:completion:
     *  fromViewController	  当前显示在父视图控制器中的子视图控制器
     *  toViewController		将要显示的姿势图控制器
     *  duration				动画时间(这个属性,old friend 了 O(∩_∩)O)
     *  options				 动画效果(渐变,从下往上等等,具体查看API)
     *  animations			  转换过程中得动画
     *  completion			  转换完成
     */
    
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentVC = newController;
            if (self.currentVC == self.questionVC) {
                [self.questionVC loadQuestionData];
            } else if (self.currentVC == self.answerVC) {
                [self.answerVC loadAnswetData];
            }
        } else {
            self.currentVC = oldController;
        }
    }];
}

@end

//
//  SJpageViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/11.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJpageViewController.h"
#import "SJselfSelectedViewController.h"
#import "SJMarkViewController.h"
#import "SJEditViewController.h"
#import "SJselfSelectedDefaultController.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"

@interface SJpageViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,SJselfSelectedDefaultControllerdelegate>

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIView *selectedLine;
@property (weak, nonatomic) IBOutlet UIView *markLine;
// 未登录界面
@property (nonatomic, strong) SJselfSelectedDefaultController *defaultvc;
// 自选股
@property (nonatomic, strong) SJselfSelectedViewController *selectedvc;
// 行情
@property (nonatomic, strong) SJMarkViewController *markvc;
@property (strong, nonatomic) UIPageViewController *pvc;
@property (strong, nonatomic) NSMutableArray *pageArr;
@property (assign, nonatomic) NSInteger pageIndext;
@property (nonatomic, assign) int flag; // 记录当前选择的页

@end

@implementation SJpageViewController

- (NSMutableArray *)pageArr {
    if (_pageArr == nil) {
        _pageArr = [NSMutableArray array];
    }
    return _pageArr;
}

- (SJselfSelectedDefaultController *)defaultvc {
    if (_defaultvc == nil) {
        _defaultvc = [[SJselfSelectedDefaultController alloc] init];
        _defaultvc.delegate = self;
    }
    
    return _defaultvc;
}

- (SJselfSelectedViewController *)selectedvc {
    if (_selectedvc == nil) {
        _selectedvc = [[SJselfSelectedViewController alloc] init];
    }
    return _selectedvc;
}

- (SJMarkViewController *)markvc {
    if (_markvc == nil) {
        _markvc = [[SJMarkViewController alloc] init];
    }
    return _markvc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (!self.pageArr.count) {
        return;
    }
    
    SJUserInfo *u = [SJUserInfo sharedUserInfo];
    if ([u isSucessLogined]) {
        [self.pageArr replaceObjectAtIndex:0 withObject:self.selectedvc];
        self.editBtn.hidden = NO;
    } else {
        [self.pageArr replaceObjectAtIndex:0 withObject:self.defaultvc];
        self.editBtn.hidden = YES;
    }
    
    WS(weakSelf);
    [self.pvc setViewControllers:[NSArray arrayWithObject:self.pageArr[self.flag]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished){
        if(finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pvc setViewControllers:[NSArray arrayWithObject:weakSelf.pageArr[weakSelf.flag]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];// bug fix for uipageview controller
            });
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _pvc = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pvc.view.frame = CGRectMake(0, HEIGHT_NAVBAR + HEIGHT_STATUSBAR, self.view.width, self.view.height - HEIGHT_NAVBAR - HEIGHT_STATUSBAR - HEIGHT_TABBAR);
    
    self.pvc.dataSource = self;
    self.pvc.delegate = self;
    self.pvc.doubleSided = YES;
    [self addChildViewController:self.pvc];
    [self.view addSubview:self.pvc.view];
    
    SJUserInfo *u = [SJUserInfo sharedUserInfo];
    if ([u isSucessLogined]) {
        [self.pageArr addObject:self.selectedvc];
        [self.pageArr addObject:self.markvc];

    } else {
        [self.pageArr addObject:self.defaultvc];
        [self.pageArr addObject:self.markvc];
    }
    
    // 设置起始主页
    WS(weakSelf);
    [self.pvc setViewControllers:[NSArray arrayWithObject:self.pageArr[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
        if(finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pvc setViewControllers:[NSArray arrayWithObject:weakSelf.pageArr[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];// bug fix for uipageview controller
            });
        }
    }];
    self.flag = 0;
}

#pragma mark -- pageviewcontroller的dataSource代理方法
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [self.pageArr indexOfObject:viewController];
    if (index == 0) {
        return nil;
    } else {
        return self.pageArr[index-1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [self.pageArr indexOfObject:viewController];
    if (index >= self.pageArr.count-1) {
        return nil;
    } else {
        return self.pageArr[index+1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    UIViewController* controller = [pendingViewControllers firstObject];
    self.pageIndext = [self.pageArr indexOfObject:controller];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        if (self.pageIndext==0) {
            self.selectedLine.hidden = NO;
            self.markLine.hidden = YES;
            self.flag = 0;
        } else {
            self.selectedLine.hidden = YES ;
            self.markLine.hidden = NO;
            self.flag = 1;
        }
    }
}

- (IBAction)selectedbtn:(UIButton *)sender {
    self.markLine.hidden = YES;
    self.selectedLine.hidden = NO;
    WS(weakSelf);
    [self.pvc setViewControllers:[NSArray arrayWithObject:self.pageArr[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished){
        if(finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pvc setViewControllers:[NSArray arrayWithObject:weakSelf.pageArr[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];// bug fix for uipageview controller
            });
        }
    }];
    self.flag = 0;
}

- (IBAction)markbtn:(UIButton *)sender {
    self.markLine.hidden = NO ;
    self.selectedLine.hidden = YES;
    WS(weakSelf);
    [self.pvc setViewControllers:[NSArray arrayWithObject:self.pageArr[1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
        if(finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pvc setViewControllers:[NSArray arrayWithObject:weakSelf.pageArr[1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];// bug fix for uipageview controller
            });
        }
    }];
    self.flag = 1;
}

- (IBAction)editBtn:(UIButton *)sender {
    SJEditViewController *editvc =[[SJEditViewController alloc]initWithNibName:@"SJEditViewController" bundle:nil];
    [self.navigationController pushViewController:editvc animated:NO];
}

- (IBAction)upDataBtn:(UIButton *)sender {
    if (self.markLine.hidden == YES && self.selectedLine.hidden == NO && [[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 刷新自选股
         [[NSNotificationCenter defaultCenter] postNotificationName:@"updataselfselected" object:nil];
    } else if (self.markLine.hidden == NO&&self.selectedLine.hidden == YES){
        // 刷新行情
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updatamark" object:nil];
    }
}

#pragma mark SJselfSelectedDefaultControllerdelegate
- (void)btnclick:(UIButton *)btn {
    SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
    [self.navigationController pushViewController:loginVC animated:YES];
}

@end

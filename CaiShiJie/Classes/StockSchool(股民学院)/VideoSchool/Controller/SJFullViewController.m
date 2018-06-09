//
//  SJFullViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/3.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJFullViewController.h"

@interface SJFullViewController ()

@end

@implementation SJFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - 横屏代码
//当前viewcontroller是否支持转屏
- (BOOL)shouldAutorotate {
    return YES;
}
//当前viewcontroller支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}
//初始方向
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

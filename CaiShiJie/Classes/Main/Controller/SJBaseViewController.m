//
//  SJBaseViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/3.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@interface SJBaseViewController ()

@end

@implementation SJBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

@end

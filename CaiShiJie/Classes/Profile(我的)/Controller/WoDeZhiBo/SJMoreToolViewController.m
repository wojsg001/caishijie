//
//  SJMoreToolViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMoreToolViewController.h"

@interface SJMoreToolViewController ()

@end

@implementation SJMoreToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)clickButtonEvents:(id)sender
{
    UIButton *btn = sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ClickWhichButton:)]) {
        [self.delegate ClickWhichButton:btn.tag];
    }
}


@end

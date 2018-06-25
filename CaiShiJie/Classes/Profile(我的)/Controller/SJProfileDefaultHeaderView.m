//
//  SJProfileDefaultHeaderView.m
//  CaiShiJie
//
//  Created by user on 18/12/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJProfileDefaultHeaderView.h"

@implementation SJProfileDefaultHeaderView

// 点击登录按钮时调用
- (IBAction)loginBtn:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickLoginButton)]) {
        [self.delegate didClickLoginButton];
    }
}

// 点击注册按钮式调用
- (IBAction)registerBtnPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickRegisterButton)]) {
        [self.delegate didClickRegisterButton];
    }
}

@end

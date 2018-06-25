//
//  SJProgressHUD.m
//  CaiShiJie
//
//  Created by user on 18/11/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJProgressHUD.h"

@implementation SJProgressHUD

+ (void)showLoadingToView:(UIView *)view {
    if (view == nil) return;
    SJProgressHUD *hud = [[SJProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 173, 75)];
    hud.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    hud.layer.cornerRadius = 5.0;
    hud.layer.masksToBounds = YES;
    hud.backgroundColor = [UIColor colorWithHexString:@"#000000" withAlpha:0.7];
    [view addSubview:hud];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"loading_icon1"], [UIImage imageNamed:@"loading_icon2"], [UIImage imageNamed:@"loading_icon3"], nil];
    imageView.animationDuration = 1;
    imageView.animationImages = images;
    [imageView startAnimating];
    [hud addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(hud);
    }];
}

+ (void)hideLoadingFromView:(UIView *)view {
    if (view == nil) return;
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

+ (void)showNetworkErrorToView:(UIView *)view reload:(ReloadBlock)reloadBlock {
    if (view == nil) return;
    SJProgressHUD *hud = [[SJProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 173, 75)];
    hud.layer.borderColor = [UIColor whiteColor].CGColor;
    hud.layer.borderWidth = 0.5;
    hud.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    hud.layer.cornerRadius = 5.0;
    hud.layer.masksToBounds = YES;
    hud.reloadBlock = reloadBlock;
    hud.backgroundColor = [UIColor colorWithHexString:@"#000000" withAlpha:0.7];
    [view addSubview:hud];
    
    [hud setupSubviews];
}

+ (void)hideNetworkErrorFromView:(UIView *)view {
    if (view == nil) return;
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

- (void)setupSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"网络连接失败";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"重新加载" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.layer.cornerRadius = 5.0;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 0.5;
    [button addTarget:self action:@selector(reloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.height.mas_equalTo(15);
        make.centerX.mas_equalTo(self);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(78);
        make.height.mas_equalTo(25);
        make.centerX.mas_equalTo(self);
    }];
}

- (void)reloadButtonClick:(UIButton *)button {
    if (self.reloadBlock) {
        self.reloadBlock();
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

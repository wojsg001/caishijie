//
//  SJNoWifiView.m
//  CaiShiJie
//
//  Created by user on 18/10/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNoWifiView.h"

@implementation SJNoWifiView

+ (void)showNoWifiViewToView:(UIView *)view delegate:(id)delegate {
    if (view == nil) return;
    SJNoWifiView *noWifiView = [[SJNoWifiView alloc] initWithFrame:view.bounds];
    noWifiView.delegate = delegate;
    [view addSubview:noWifiView];
}

+ (void)hideNoWifiViewFromView:(UIView *)view {
    if (view == nil) return;
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"loading_icon"];
    [self addSubview:imageView];
    
    
    UILabel *labelOne = [[UILabel alloc] init];
    labelOne.text = @"数据加载失败";
    labelOne.textColor = [UIColor colorWithHexString:@"#545454" withAlpha:1];
    labelOne.font = [UIFont systemFontOfSize:15];
    [self addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] init];
    labelTwo.text = @"请检查您的手机是否连上网";
    labelTwo.textColor = [UIColor colorWithHexString:@"#888888" withAlpha:1];
    labelTwo.font = [UIFont systemFontOfSize:14];
    [self addSubview:labelTwo];
    
    UILabel *labelThree = [[UILabel alloc] init];
    labelThree.text = @"点击按钮尝试重新加载";
    labelThree.textColor = [UIColor colorWithHexString:@"#888888" withAlpha:1];
    labelThree.font = [UIFont systemFontOfSize:14];
    [self addSubview:labelThree];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"重新加载" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#545454" withAlpha:1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.layer.borderColor = [UIColor colorWithHexString:@"#747474" withAlpha:1].CGColor;
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(refreshButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
    
    WS(weakSelf);
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf);
        make.centerY.equalTo(weakSelf.mas_centerY).offset(-100);
    }];
    
    [labelOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(25);
        make.centerX.mas_equalTo(weakSelf);
        make.height.mas_equalTo(15);
    }];
    
    [labelTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelOne.mas_bottom).offset(18);
        make.centerX.mas_equalTo(weakSelf);
        make.height.mas_equalTo(14);
    }];
    
    [labelThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelTwo.mas_bottom).offset(8);
        make.centerX.mas_equalTo(weakSelf);
        make.height.mas_equalTo(14);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelThree.mas_bottom).offset(25);
        make.centerX.mas_equalTo(weakSelf);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
    }];
}

- (void)refreshButtonDown:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshNetwork)]) {
        [self.delegate refreshNetwork];
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

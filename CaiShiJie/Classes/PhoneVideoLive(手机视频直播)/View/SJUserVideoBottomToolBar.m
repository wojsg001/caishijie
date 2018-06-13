//
//  SJUserVideoBottomToolBar.m
//  CaiShiJie
//
//  Created by user on 16/7/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserVideoBottomToolBar.h"

@interface SJUserVideoBottomToolBar ()

@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *giftButton;
@property (nonatomic, strong) UIButton *fullButton;

@end

@implementation SJUserVideoBottomToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews {
    _chatButton = [[UIButton alloc] init];
    [_chatButton setImage:[UIImage imageNamed:@"live_down_icon1"] forState:UIControlStateNormal];
    _chatButton.tag = 101;
    [_chatButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chatButton];
    
    _recordButton = [[UIButton alloc] init];
    [_recordButton setImage:[UIImage imageNamed:@"live_down_icon2"] forState:UIControlStateNormal];
    _recordButton.tag = 102;
    [_recordButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recordButton];
    
    _giftButton = [[UIButton alloc] init];
    [_giftButton setImage:[UIImage imageNamed:@"live_down_icon3"] forState:UIControlStateNormal];
    _giftButton.tag = 103;
    [_giftButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_giftButton];
    
    _fullButton = [[UIButton alloc] init];
    [_fullButton setImage:[UIImage imageNamed:@"live_down_icon4"] forState:UIControlStateNormal];
    _fullButton.tag = 104;
    [_fullButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_fullButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    WS(weakSelf);
    [_chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(10);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
    
    [_fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_right).offset(-10);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
    
    [_giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.fullButton.mas_left).offset(-15);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
    
    [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.giftButton.mas_left).offset(-15);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
}

- (void)clickButtonEvent:(UIButton *)sender {
    if (self.clickButtonEventBlock) {
        self.clickButtonEventBlock(sender.tag);
    }
}

@end

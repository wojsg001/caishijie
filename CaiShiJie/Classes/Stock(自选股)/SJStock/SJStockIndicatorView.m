//
//  SJStockIndicatorView.m
//  CaiShiJie
//
//  Created by user on 18/9/28.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJStockIndicatorView.h"
#import "UIColor+helper.h"

@interface SJStockIndicatorView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation SJStockIndicatorView

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
        _textLabel.font = [UIFont systemFontOfSize:15];
    }
    return _textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
        [self showProgressHUDMessage:@"数据加载中..."];
    }
    return self;
}

- (void)setupChildViews {
    _backgroundView = [[UIView alloc] init];
    _backgroundView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    _backgroundView.layer.borderWidth = 0.5f;
    [self addSubview:_backgroundView];
    WS(weakSelf);
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(60);
    }];
}

- (void)showProgressHUDMessage:(NSString *)message {
    WS(weakSelf);
    [self.activityIndicatorView startAnimating];
    [self.backgroundView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.backgroundView.mas_left).offset(15);
        make.centerY.mas_equalTo(weakSelf.backgroundView);
    }];
    
    self.textLabel.text = message;
    [self.backgroundView addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.activityIndicatorView.mas_right).offset(10);
        make.centerY.mas_equalTo(weakSelf.backgroundView);
    }];
}

- (void)hideProgressHUD {
    [self.activityIndicatorView removeFromSuperview];
    [self.textLabel removeFromSuperview];
    self.activityIndicatorView = nil;
    self.textLabel = nil;
}

- (void)showAlertMessage:(NSString *)message {
    [self hideProgressHUD];
    self.textLabel.text = message;
    [self.backgroundView addSubview:self.textLabel];
    WS(weakSelf);
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.backgroundView);
    }];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

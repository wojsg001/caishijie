//
//  SJNewLiveVideoAboveView.m
//  CaiShiJie
//
//  Created by user on 18/9/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNewLiveVideoAboveView.h"

@interface SJNewLiveVideoAboveView ()

@property (nonatomic, strong) UIImageView *coverPicture;
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *fullButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) BOOL isHUDShowing;
@property (nonatomic, strong) NSTimer *clickTimer;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation SJNewLiveVideoAboveView

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:_singleTap];
    }
    return _singleTap;
}

- (UIImageView *)coverPicture {
    if (!_coverPicture) {
        _coverPicture = [[UIImageView alloc] init];
        _coverPicture.image = [UIImage imageNamed:@"live_bg1"];
    }
    return _coverPicture;
}

- (UIButton *)centerButton {
    if (!_centerButton) {
        _centerButton = [[UIButton alloc] init];
        [_centerButton setImage:[UIImage imageNamed:@"none_live"] forState:UIControlStateNormal];
        _centerButton.tag = 204;
        [_centerButton addTarget:self action:@selector(playerViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerButton;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"end_live_icon_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"end_live_icon_stop"] forState:UIControlStateSelected];
        _playButton.tag = 201;
        _playButton.selected = NO;
        [_playButton addTarget:self action:@selector(playerViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"end_live_navbar"] forState:UIControlStateNormal];
        _backButton.tag = 202;
        [_backButton addTarget:self action:@selector(playerViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)fullButton {
    if (_fullButton == nil) {
        _fullButton = [[UIButton alloc] init];
        [_fullButton setImage:[UIImage imageNamed:@"end_live_icon_small"] forState:UIControlStateNormal];
        _fullButton.tag = 203;
        [_fullButton addTarget:self action:@selector(playerViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isHUDShowing = NO; // 默认HUD未显示
        self.backgroundColor = [UIColor clearColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setProgressHUD {
    _hud = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:_hud];
    [self sendSubviewToBack:_hud];
    _hud.color = [UIColor clearColor];
    _hud.dimBackground = NO;
    _hud.labelText = nil;
    _hud.labelFont = [UIFont systemFontOfSize:14];
    _hud.removeFromSuperViewOnHide = YES;
}

- (void)showProgressHUD {
    if (_isHUDShowing) {
        return;
    }
    
    [self setProgressHUD];
    [_hud showAnimated:YES whileExecutingBlock:^{
        _isHUDShowing = YES;
        sleep(60);
    } completionBlock:^{
        _isHUDShowing = NO;
        [_hud removeFromSuperview];
        _hud = nil;
    }];
}

- (void)hideProgressHUD {
    if (_hud != nil && _isHUDShowing) {
        _isHUDShowing = NO;
        [_hud hide:YES];
    }
}

- (void)setProgressHUDMessage:(NSString *)message {
    _hud.labelText = message;
}

- (void)showCenterButton {
    [self addSubview:self.centerButton];
    WS(weakSelf);
    [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
    }];
}

- (void)HideCenterButton {
    [self.centerButton removeFromSuperview];
    self.centerButton = nil;
}

- (void)showCoverPicture {
    [self addSubview:self.coverPicture];
    [self sendSubviewToBack:self.coverPicture];
    [self.coverPicture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)HideCoverPicture {
    [self.coverPicture removeFromSuperview];
    self.coverPicture = nil;
}

- (void)setCoverPictureWithUrlString:(NSString *)urlString {
    [self.coverPicture sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"live_bg1"]];
}

- (void)setPlayButtonSelected:(BOOL)isSelected {
    self.playButton.selected = isSelected;
}

- (void)setPlayButtonAndFullButtonHide:(BOOL)isHide {
    self.playButton.hidden = isHide;
    self.fullButton.hidden = isHide;
}

- (void)addSingleGesture {
    [self.singleTap addTarget:self action:@selector(singleTapEvent)];
}

- (void)removeSingleGesture {
    [self.singleTap removeTarget:self action:@selector(singleTapEvent)];
    if (self.backButton.alpha == 0.0) {
        self.backButton.alpha = 1.0;
        self.playButton.alpha = 1.0;
        self.fullButton.alpha = 1.0;
    }
}

/**
 *  单击手势
 */
- (void)singleTapEvent {
    if (self.backButton.alpha == 1.0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.backButton.alpha = 0.0;
            self.playButton.alpha = 0.0;
            self.fullButton.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.backButton.alpha = 1.0;
            self.playButton.alpha = 1.0;
            self.fullButton.alpha = 1.0;
        }];
    }
    [self resetTimer];
}
/**
 *  创建定时器
 */
- (void)resetTimer {
    if (!_clickTimer) {
        _clickTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerExceeded) userInfo:nil repeats:NO];
    } else {
        if (fabs([self.clickTimer.fireDate timeIntervalSinceNow]) < 5.0) {
            [self.clickTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        }
    }
}

- (void)timerExceeded {
    [self.clickTimer invalidate];
    self.clickTimer = nil;
    [UIView animateWithDuration:0.25 animations:^{
        self.backButton.alpha = 0.0;
        self.playButton.alpha = 0.0;
        self.fullButton.alpha = 0.0;
    }];
}

- (void)setupChildViews {
    [self addSubview:self.playButton];
    [self addSubview:self.backButton];
    [self addSubview:self.fullButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(10);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(10);
        make.top.equalTo(weakSelf.mas_top).offset(10);
    }];
    [self.fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_right).offset(-10);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
}

- (void)playerViewButtonClicked:(UIButton *)button {
    if (self.liveVideoAboveViewButtonClickedBlock) {
        self.liveVideoAboveViewButtonClickedBlock(button);
    }
}


@end

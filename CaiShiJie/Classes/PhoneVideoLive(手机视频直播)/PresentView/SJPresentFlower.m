//
//  SJPresentFlower.m
//  CaiShiJie
//
//  Created by user on 16/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPresentFlower.h"
#import "SJShakeLabel.h"
#import "SJGiftModel.h"

@interface SJPresentFlower ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIImageView *giftImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *giftLabel;
@property (nonatomic, strong) SJShakeLabel *shakeLabel;

/**
 新增了回调参数finishCount，用来记录动画结束时累加数量，将来在3秒内，还能继续累加
 */
@property (nonatomic, copy) CompleteBlcok completeBlock;

@end

@implementation SJPresentFlower

/**
 根据礼物个数播放动画

 @param completed 回调
 */
- (void)animateWithCompleteBlock:(CompleteBlcok)completed {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self shakeNumberLabel];
    }];
    self.completeBlock = completed;
}

- (void)shakeNumberLabel {
    _animCount ++;
    // 可以取消成功
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePresentView) object:nil];
    [self performSelector:@selector(hidePresentView) withObject:nil afterDelay:2];
    
    self.shakeLabel.text = [NSString stringWithFormat:@"X %ld", (long)_animCount];
    [self.shakeLabel startAnimWithDuration:0.3];
}

- (void)hidePresentView {
    [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(0, self.frame.origin.y - 20, self.frame.size.width, self.frame.size.height);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.completeBlock) {
            self.completeBlock(finished, _animCount);
        }
        [self reset];
        _finished = finished;
        [self removeFromSuperview];
    }];
}

/**
 重置
 */
- (void)reset {
    self.frame = _originFrame;
    self.alpha = 1;
    self.animCount = 0;
    self.shakeLabel.text = @"";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _originFrame = frame;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.backgroundColor = [UIColor clearColor];
    _bgImageView.image = [UIImage imageNamed:@"gift_bagimage"];
    
    _headImageView = [[UIImageView alloc] init];
    _headImageView.backgroundColor = [UIColor clearColor];
    _headImageView.layer.cornerRadius = 18.5;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _headImageView.layer.borderWidth = 2.0;
    
    _giftImageView = [[UIImageView alloc] init];
    _giftImageView.backgroundColor = [UIColor clearColor];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    
    _giftLabel = [[UILabel alloc] init];
    _giftLabel.textColor = [UIColor colorWithHexString:@"#fffd39" withAlpha:1];
    _giftLabel.font = [UIFont systemFontOfSize:13];
    
    _shakeLabel = [[SJShakeLabel alloc] init];
    _shakeLabel.textColor = [UIColor colorWithHexString:@"#f7f006" withAlpha:1];
    _shakeLabel.borderColer = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    _shakeLabel.font = [UIFont systemFontOfSize:21];
    _shakeLabel.textAlignment = NSTextAlignmentCenter;
    _animCount = 0;
    
    [self addSubview:_bgImageView];
    [self addSubview:_headImageView];
    [self addSubview:_giftImageView];
    [self addSubview:_nameLabel];
    [self addSubview:_giftLabel];
    [self addSubview:_shakeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(0);
    }];
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.width.height.mas_equalTo(37);
        make.centerY.mas_equalTo(weakSelf);
    }];
    
    [_giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(49);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headImageView.mas_right).offset(7);
        make.right.equalTo(weakSelf.giftImageView.mas_left).offset(-7);
        make.top.mas_equalTo(6);
        make.height.mas_equalTo(13);
    }];
    
    [_giftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headImageView.mas_right).offset(7);
        make.right.equalTo(weakSelf.giftImageView.mas_left).offset(-7);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(13);
    }];
    
    [_shakeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.giftImageView.mas_right).offset(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(50);
    }];
}

- (void)setModel:(SJGiftModel *)model {
    _model = model;
    
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    [_giftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://common.csjimg.com/gift/%@", _model.img]] placeholderImage:[UIImage imageNamed:@"live_gift_img_n"]];
    _nameLabel.text = _model.nickname;
    _giftLabel.text = [NSString stringWithFormat:@"送了%@", _model.gift_name];
    _giftCount = _model.giftCount;
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

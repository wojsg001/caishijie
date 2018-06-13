//
//  SJMineMessageCell.m
//  CaiShiJie
//
//  Created by user on 16/10/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMineMessageCell.h"
#import "SJMineMessageModel.h"
#import "SDAutoLayout.h"
#import "UIView+ITTAdditions.h"
#define kDeleteButtonWidth      60.0f
#define kTagButtonWidth         0.0f
#define kCriticalTranslationX   30
#define kShouldSlideX           -2
#define kHeadImageWH            50

@interface SJMineMessageCell ()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *badgeValue;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (assign, nonatomic) BOOL isSlided;

@end

@implementation SJMineMessageCell
{
    UIButton *_deleteButton;
    UIButton *_tagButton;
    
    UIPanGestureRecognizer *_pan;
    UITapGestureRecognizer *_tap;
    
    BOOL _shouldSlide;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJMineMessageCell";
    SJMineMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJMineMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubViews];
        [self setupGestureRecognizer];
    }
    return self;
}

- (void)setupSubViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconImageView = [UIImageView new];
    _iconImageView.layer.cornerRadius = kHeadImageWH/2;
    _iconImageView.layer.masksToBounds = YES;
    
    _badgeValue = [UILabel new];
    _badgeValue.textColor = [UIColor whiteColor];
    _badgeValue.font = [UIFont systemFontOfSize:10];
    _badgeValue.backgroundColor = [UIColor colorWithHexString:@"#d94332" withAlpha:1];
    _badgeValue.textAlignment = NSTextAlignmentCenter;
    _badgeValue.layer.cornerRadius = 8;
    _badgeValue.layer.masksToBounds = YES;
    
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor colorWithHexString:@"#848484" withAlpha:1];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    
    _timeLabel = [UILabel new];
    _timeLabel.textColor = [UIColor colorWithHexString:@"#999999" withAlpha:1];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    
    _deleteButton = [UIButton new];
    _deleteButton.backgroundColor = [UIColor redColor];
    [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    _deleteButton.tag = 101;
    [_deleteButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _tagButton = [UIButton new];
    _tagButton.backgroundColor =[UIColor lightGrayColor];
    [_tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_tagButton setTitle:@"标记未读" forState:UIControlStateNormal];
    _tagButton.tag = 102;
    _tagButton.hidden = YES;
    [_tagButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_iconImageView];
    [self.contentView addSubview:_badgeValue];
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_contentLabel];
    [self.contentView addSubview:_timeLabel];
    [self insertSubview:_deleteButton belowSubview:self.contentView];
    [self insertSubview:_tagButton belowSubview:self.contentView];
    
    _deleteButton.sd_layout
    .topEqualToView(self)
    .rightEqualToView(self)
    .bottomEqualToView(self)
    .widthIs(kDeleteButtonWidth);
    
    _tagButton.sd_layout
    .topEqualToView(_deleteButton)
    .bottomEqualToView(_deleteButton)
    .rightSpaceToView(_deleteButton, 0)
    .widthIs(kTagButtonWidth);
    
    _iconImageView.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .centerYEqualToView(self.contentView)
    .widthIs(kHeadImageWH)
    .heightIs(kHeadImageWH);
    
    _badgeValue.sd_layout
    .leftSpaceToView(self.contentView, 51)
    .topSpaceToView(self.contentView, 5)
    .heightIs(16); // 宽度根据内容改变
    
    _titleLabel.sd_layout
    .leftSpaceToView(self.iconImageView, 15)
    .topSpaceToView(self.contentView, 15)
    .heightIs(16);
    [_titleLabel setSingleLineAutoResizeWithMaxWidth:160];
    
    _contentLabel.sd_layout
    .leftEqualToView(self.titleLabel)
    .topSpaceToView(self.titleLabel, 10)
    .rightSpaceToView(self.contentView, 10)
    .heightIs(14);
    
    _timeLabel.sd_layout
    .topSpaceToView(self.contentView, 15)
    .rightSpaceToView(self.contentView, 10)
    .heightIs(12);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:SJScreenW];
}

- (void)setupGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    _pan = pan;
    pan.delegate = self;
    pan.delaysTouchesBegan = YES;
    [self.contentView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.delegate = self;
    tap.enabled = NO;
    [self.contentView addGestureRecognizer:tap];
    _tap = tap;
}

- (void)tapView:(UITapGestureRecognizer *)tap {
    if (self.isSlided) {
        [self cellSlideAnimationWithX:0];
    }
}

- (void)panView:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:pan.view];
    
    if (self.contentView.left <= kShouldSlideX) {
        _shouldSlide = YES;
    }
    
    if (fabs(point.y) < 1.0) {
        if (_shouldSlide) {
            [self slideWithTranslation:point.x];
        } else if (fabs(point.x) >= 1.0) {
            [self slideWithTranslation:point.x];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        CGFloat x = 0;
        if (self.contentView.left < -kCriticalTranslationX && !self.isSlided) {
            x = -(kDeleteButtonWidth + kTagButtonWidth);
        }
        [self cellSlideAnimationWithX:x];
        _shouldSlide = NO;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)cellSlideAnimationWithX:(CGFloat)x {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:2 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentView.left = x;
    } completion:^(BOOL finished) {
        self.isSlided = (x != 0);
    }];
}

- (void)slideWithTranslation:(CGFloat)value {
    if (self.contentView.left < -(kDeleteButtonWidth + kTagButtonWidth) * 1.1 || self.contentView.left > 30) {
        value = 0;
    }
    self.contentView.left += value;
}

- (void)setIsSlided:(BOOL)isSlided {
    _isSlided = isSlided;
    
    _tap.enabled = isSlided;
}

- (void)setModel:(SJMineMessageModel *)model {
    _model = model;
    
    if ([_model.count integerValue] == 0) {
        self.badgeValue.hidden = YES;
    } else if ([_model.count integerValue] < 10) {
        self.badgeValue.hidden = NO;
        _badgeValue.sd_layout
        .widthIs(16);
        self.badgeValue.text = _model.count;
    } else if ([_model.count integerValue] < 100) {
        self.badgeValue.hidden = NO;
        _badgeValue.sd_layout
        .widthIs(23);
        self.badgeValue.text = _model.count;
    } else {
        self.badgeValue.hidden = NO;
        _badgeValue.sd_layout
        .widthIs(23);
        self.badgeValue.text = @"···";
    }
    
    if ([_model.type isEqualToString:@"30"]) {
        _pan.enabled = NO;
        NSDictionary *dic = [SJUserDefaults objectForKey:kUserInfo];
        if ([dic[@"level"] isEqualToString:@"10"]) {
            self.titleLabel.text = @"提问我的";
        } else {
            self.titleLabel.text = @"回答我的";
        }
        self.iconImageView.image = [UIImage imageNamed:@"sixin_list_icon_06"];
    } else if ([_model.type isEqualToString:@"0"]) {
        _pan.enabled = NO;
        self.titleLabel.text = @"财视界通知";
        self.iconImageView.image = [UIImage imageNamed:@"sixin_list_icon_03"];
    } else {
        _pan.enabled = YES;
        self.titleLabel.text = _model.nickname;
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    }

    self.timeLabel.text = _model.created_at;
    self.contentLabel.attributedText = _model.contentAttributedString;
}

#pragma mark - gestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.contentView.left <= kShouldSlideX && otherGestureRecognizer != _pan && otherGestureRecognizer != _tap) {
        return NO;
    }
    return YES;
}

- (void)buttonClicked:(UIButton *)button {
    if (self.buttonClickedBlock) {
        self.buttonClickedBlock(button);
    }
}

@end

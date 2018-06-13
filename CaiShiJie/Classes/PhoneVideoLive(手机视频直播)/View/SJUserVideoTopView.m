//
//  SJUserVideoTopView.m
//  CaiShiJie
//
//  Created by user on 16/7/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserVideoTopView.h"
#import "SJVideoTeacherInfoModel.h"

@interface SJUserVideoTopView ()

@property (nonatomic, strong) UIImageView *headIcon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *attentionButton;
@property (nonatomic, strong) UITapGestureRecognizer *singleGestureRecognizer;

@end

@implementation SJUserVideoTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" withAlpha:0.3];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews {
    _headIcon = [[UIImageView alloc] init];
    _headIcon.image = [UIImage imageNamed:@"icon_teacher"];
    _headIcon.layer.cornerRadius = 29/2;
    _headIcon.layer.masksToBounds = YES;
    // 添加单击手势
    _headIcon.userInteractionEnabled = YES;
    [_headIcon addGestureRecognizer:self.singleGestureRecognizer];
    [self addSubview:_headIcon];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"----";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_titleLabel];
    
    _countLabel = [[UILabel alloc] init];
    _countLabel.text = @"----";
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_countLabel];
    
    _attentionButton = [[UIButton alloc] init];
    [_attentionButton setTitle:@"关注" forState:UIControlStateNormal];
    [_attentionButton setTitle:@"已关注" forState:UIControlStateSelected];
    [_attentionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _attentionButton.titleLabel.font = [UIFont systemFontOfSize:10];
    _attentionButton.layer.borderColor = RGB(243, 76, 12).CGColor;
    _attentionButton.layer.borderWidth = 1.0f;
    _attentionButton.layer.cornerRadius = 9;
    _attentionButton.layer.masksToBounds = YES;
    [_attentionButton addTarget:self action:@selector(attentionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_attentionButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = YES;
    
    WS(weakSelf);
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(29);
        make.left.equalTo(weakSelf.mas_left).offset(3);
        make.centerY.mas_equalTo(weakSelf);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headIcon.mas_right).offset(7);
        make.top.equalTo(weakSelf.mas_top).offset(5);
    }];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset(5);
        make.centerX.equalTo(weakSelf.titleLabel.mas_centerX).offset(0);
    }];
    
    [_attentionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.titleLabel.mas_right).offset(7);
        make.right.equalTo(weakSelf.mas_right).offset(-5);
        make.height.mas_equalTo(18);
        make.centerY.mas_equalTo(weakSelf);
    }];
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
    
    [_headIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    _titleLabel.text = _model.nickname;
    _countLabel.text = _model.total_count;
    
    if ([_model.isFocus isEqualToString:@"0"]) {
        _attentionButton.selected = NO;
        _attentionButton.userInteractionEnabled = YES;
    } else {
        _attentionButton.selected = YES;
        _attentionButton.userInteractionEnabled = NO;
    }
}

#pragma mark - 懒加载
- (UITapGestureRecognizer *)singleGestureRecognizer {
    if (!_singleGestureRecognizer) {
        _singleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGestureRecognizerClicked:)];
        _singleGestureRecognizer.numberOfTapsRequired = 1;
        _singleGestureRecognizer.numberOfTouchesRequired = 1;
    }
    return _singleGestureRecognizer;
}

#pragma mark - 点击事件
- (void)singleGestureRecognizerClicked:(UITapGestureRecognizer *)single {
    // 点击了用户头像
    if (self.clickUserHeadImageBlock) {
        self.clickUserHeadImageBlock();
    }
}

- (void)attentionButtonClicked:(UIButton *)button {
    if (self.clickUserAttentionButtonBlock) {
        self.clickUserAttentionButtonBlock(button);
    }
}

@end

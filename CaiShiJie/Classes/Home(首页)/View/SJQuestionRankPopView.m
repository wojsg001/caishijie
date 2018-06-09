//
//  SJQuestionRankPopView.m
//  CaiShiJie
//
//  Created by user on 16/4/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJQuestionRankPopView.h"
#import "Masonry.h"

@interface SJQuestionRankPopView ()

@property (nonatomic, strong) UIView      *view1;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UILabel     *label1;
@property (nonatomic, strong) UIView      *line1;
@property (nonatomic, strong) UIButton    *button1;
@property (nonatomic, strong) UIView      *view2;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UILabel     *label2;
@property (nonatomic, strong) UIView      *line2;
@property (nonatomic, strong) UIButton    *button2;
@property (nonatomic, strong) UIView      *view3;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UILabel     *label3;
@property (nonatomic, strong) UIButton    *button3;

@end

@implementation SJQuestionRankPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    WS(weakSelf);
    _view1 = [[UIView alloc] init];
    [self addSubview:_view1];
    [_view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
    
    _imageView1 = [[UIImageView alloc] init];
    _imageView1.image = [UIImage imageNamed:@"rank_ask_more_icon1"];
    [_view1 addSubview:_imageView1];
    [_imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.view1);
        make.left.mas_equalTo(15);
    }];
    
    _label1 = [[UILabel alloc] init];
    _label1.font = [UIFont systemFontOfSize:16];
    _label1.textColor = RGB(68, 68, 68);
    _label1.text = @"去提问";
    [_view1 addSubview:_label1];
    [_label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.view1);
        make.left.equalTo(weakSelf.imageView1.mas_right).offset(15);
    }];
    
    _line1 = [[UIView alloc] init];
    _line1.backgroundColor = RGB(235, 234, 234);
    [_view1 addSubview:_line1];
    [_line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.label1.mas_left).offset(0);
        make.right.equalTo(weakSelf.view1.mas_right).offset(0);
        make.bottom.equalTo(weakSelf.view1.mas_bottom).offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    _button1 = [[UIButton alloc] init];
    _button1.tag = 101;
    [_button1 addTarget:self action:@selector(clickButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_view1 addSubview:_button1];
    [_button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(weakSelf.view1);
    }];
    
    _view2 = [[UIView alloc] init];
    [self addSubview:_view2];
    [_view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view1.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
    
    _imageView2 = [[UIImageView alloc] init];
    _imageView2.image = [UIImage imageNamed:@"rank_ask_more_icon2"];
    [_view2 addSubview:_imageView2];
    [_imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.view2);
        make.left.mas_equalTo(15);
    }];
    
    _label2 = [[UILabel alloc] init];
    _label2.font = [UIFont systemFontOfSize:16];
    _label2.textColor = RGB(68, 68, 68);
    _label2.text = @"进入直播室";
    [_view2 addSubview:_label2];
    [_label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.view2);
        make.left.equalTo(weakSelf.imageView2.mas_right).offset(15);
    }];
    
    _line2 = [[UIView alloc] init];
    _line2.backgroundColor = RGB(235, 234, 234);
    [_view2 addSubview:_line2];
    [_line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.label2.mas_left).offset(0);
        make.right.equalTo(weakSelf.view2.mas_right).offset(0);
        make.bottom.equalTo(weakSelf.view2.mas_bottom).offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    _button2 = [[UIButton alloc] init];
    _button2.tag = 102;
    [_button2 addTarget:self action:@selector(clickButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_view2 addSubview:_button2];
    [_button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(weakSelf.view2);
    }];
    
    _view3 = [[UIView alloc] init];
    [self addSubview:_view3];
    [_view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view2.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
    
    _imageView3 = [[UIImageView alloc] init];
    _imageView3.image = [UIImage imageNamed:@"rank_ask_more_icon3"];
    [_view3 addSubview:_imageView3];
    [_imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.view3);
        make.left.mas_equalTo(15);
    }];
    
    _label3 = [[UILabel alloc] init];
    _label3.font = [UIFont systemFontOfSize:16];
    _label3.textColor = RGB(68, 68, 68);
    _label3.text = @"加关注";
    [_view3 addSubview:_label3];
    [_label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.view3);
        make.left.equalTo(weakSelf.imageView3.mas_right).offset(15);
    }];
    
    _button3 = [[UIButton alloc] init];
    _button3.tag = 103;
    [_button3 addTarget:self action:@selector(clickButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_view3 addSubview:_button3];
    [_button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(weakSelf.view3);
    }];
}

- (void)clickButtonDown:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(questionRankPopView:clickButtonDown:)])
    {
        [self.delegate questionRankPopView:self clickButtonDown:sender.tag];
    }
}

@end

//
//  SJNewReferenceTitleView.m
//  CaiShiJie
//
//  Created by user on 18/3/30.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAddReferenceTitleView.h"
#import "Masonry.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface SJAddReferenceTitleView ()

@property (weak, nonatomic) UIView *bgview;
@property (weak, nonatomic) UILabel *titleLabel;

@end

@implementation SJAddReferenceTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        // 添加所有子控件
        [self setUpAllChildView];
    }
    return self;
}

#pragma mark - 添加所有子控件
- (void)setUpAllChildView
{
    UIView *bgview = [[UIView alloc] init];
    bgview.backgroundColor = [UIColor whiteColor];
    bgview.layer.cornerRadius = 5;
    bgview.layer.masksToBounds = YES;
    [self addSubview:bgview];
    _bgview = bgview;
    

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"标题:";
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = RGB(153, 153, 153);
    [titleLabel sizeToFit];
    [bgview addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    
    UITextField *titleTextField = [[UITextField alloc] init];
    titleTextField.text = @"3月25日股市早盘内参";
    titleTextField.font = [UIFont systemFontOfSize:17];
    titleTextField.textColor = RGB(51, 51, 51);
    [bgview addSubview:titleTextField];
    _titleTextField = titleTextField;
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-5);
        make.right.mas_equalTo(-15);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_titleLabel.size.width);
        make.left.equalTo(_bgview.mas_left).offset(5);
        make.centerY.equalTo(_bgview.mas_centerY).offset(0);
    }];
    
    [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).offset(12);
        make.right.equalTo(_bgview.mas_right).offset(-5);
        make.centerY.equalTo(_bgview.mas_centerY).offset(0);
    }];
}

@end

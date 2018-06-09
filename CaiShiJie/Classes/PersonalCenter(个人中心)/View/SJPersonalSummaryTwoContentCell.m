//
//  SJPersonalSummaryTwoContentCell.m
//  CaiShiJie
//
//  Created by user on 16/10/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalSummaryTwoContentCell.h"
#import "UIColor+helper.h"

@interface SJPersonalSummaryTwoContentCell ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation SJPersonalSummaryTwoContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initChildViews];
    }
    return self;
}

- (void)initChildViews {
    _textLabel = [[UILabel alloc] init];
    _textLabel.textColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    _textLabel.font = [UIFont systemFontOfSize:14];
    _textLabel.layer.borderColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1].CGColor;
    _textLabel.layer.borderWidth = 0.5f;
    _textLabel.layer.cornerRadius = 5;
    _textLabel.layer.masksToBounds = YES;
    _textLabel.backgroundColor = [UIColor colorWithHexString:@"#fdf0e5" withAlpha:1];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    WS(weakSelf);
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(7.5);
        make.right.mas_equalTo(-7.5);
        make.height.mas_equalTo(25);
        make.centerY.mas_equalTo(weakSelf);
    }];
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = title;
    }
    _textLabel.text = title;
}

@end

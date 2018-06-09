//
//  SJTextView.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTextView.h"

@interface SJTextView ()

@property (nonatomic, weak) UILabel *placeHolderLabel;

@end

@implementation SJTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = RGB(68, 68, 68);
    }
    return self;
}

- (UILabel *)placeHolderLabel
{
    if (_placeHolderLabel == nil) {
        
        UILabel *label = [[UILabel alloc] init];
        
        [self addSubview:label];
        
        _placeHolderLabel = label;
        _placeHolderLabel.textColor = RGB(153, 153, 153);
        
    }
    
    return _placeHolderLabel;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeHolderLabel.font = font;
    [self.placeHolderLabel sizeToFit];
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    
    self.placeHolderLabel.text = placeHolder;
    // label的尺寸跟文字一样
    [self.placeHolderLabel sizeToFit];
}

- (void)setHidePlaceHolder:(BOOL)hidePlaceHolder
{
    _hidePlaceHolder = hidePlaceHolder;
    
    
    self.placeHolderLabel.hidden = hidePlaceHolder;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.placeHolderLabelX)
    {
        self.placeHolderLabel.x = self.placeHolderLabelX;
        self.placeHolderLabel.y = self.placeHolderLabelY;
    }
    else
    {
        self.placeHolderLabel.x = 10;
        self.placeHolderLabel.y = 10;
    }
}

@end

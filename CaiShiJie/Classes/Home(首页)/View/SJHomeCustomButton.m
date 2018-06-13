//
//  SJHomeCustomButton.m
//  CaiShiJie
//
//  Created by user on 16/12/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHomeCustomButton.h"

@implementation SJHomeCustomButton

// 重写setHighlighted，取消高亮做的事情
- (void)setHighlighted:(BOOL)highlighted{}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageX = 0;
    CGFloat imageY = 10;
    CGFloat imageW = self.bounds.size.width;
    CGFloat imageH = self.imageView.frame.size.height;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    CGFloat titleX = 0;
    CGFloat titleY = CGRectGetMaxY(self.imageView.frame) + 8;
    CGFloat titleW = self.bounds.size.width;
    CGFloat titleH = self.titleLabel.frame.size.height;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
}

@end

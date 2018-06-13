//
//  SJPopMenu.m
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPopMenu.h"
#import "SJBombBox.h"

@implementation SJPopMenu

+ (instancetype)showInRect:(CGRect)rect {
    SJPopMenu *menu = [[SJPopMenu alloc]initWithFrame:rect];
    menu.userInteractionEnabled = YES;
    menu.image = [UIImage resizableImageWithName:@"live_bagimg"];
    
    [SJKeyWindow addSubview:menu];
    
    return menu;
}

+ (void)hide {
    for (UIView *popmenu in SJKeyWindow.subviews) {
        if ([popmenu isKindOfClass:self]) {
            [popmenu removeFromSuperview];
        }
    }
}

// 设置内容视图
- (void)setContentView:(UIView *)contentView {
    // 先移除之前内容视图
    [_contentView removeFromSuperview];
    _contentView = contentView;
    
    [self addSubview:contentView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    //计算内荣视图尺寸
    CGFloat y = 10;
    CGFloat margin = 5;
    CGFloat x = margin;
    CGFloat w = self.width - 2 * margin;
    CGFloat h = self.height - y - margin;
    
    _contentView.frame =CGRectMake(x, y, w, h);
}

@end

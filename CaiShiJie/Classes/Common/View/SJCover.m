//
//  SJCover.m
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCover.h"

@implementation SJCover

-(void)setDidBackground:(BOOL)didBackground {
    _didBackground =didBackground;
    if (didBackground) {
        self.backgroundColor =[UIColor blackColor];
        self.alpha =0.5;
    } else {
        self.alpha =1;
        self.backgroundColor =[UIColor clearColor];
    }
}

//显示蒙版
+ (instancetype)show {
    SJCover *cover =[[SJCover alloc]initWithFrame:[UIScreen mainScreen].bounds];
    cover.backgroundColor =[UIColor clearColor];
    [SJKeyWindow addSubview:cover];
    return cover;
    
}

//点击蒙版做的事
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(coverClick:)]) {
        [_delegate coverClick:self];
    }
}

+ (void)hide {
    for (UIView *cover in SJKeyWindow.subviews) {
        if ([cover isKindOfClass:self]) {
            [cover removeFromSuperview];
        }
    }
}

@end

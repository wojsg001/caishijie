//
//  UIScrollView+SJ.m
//  CaiShiJie
//
//  Created by user on 16/11/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "UIScrollView+SJ.h"

@implementation UIScrollView (SJ)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    } else {
        return  NO;
    }
}

@end

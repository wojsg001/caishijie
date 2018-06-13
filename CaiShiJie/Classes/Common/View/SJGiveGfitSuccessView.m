//
//  SJGiveGfitSuccessView.m
//  CaiShiJie
//
//  Created by user on 16/11/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGiveGfitSuccessView.h"

#define KDefaultH 255
#define KDefaultW 290
#define KDefaultTag 1111

@implementation SJGiveGfitSuccessView

+ (void)showSuccessViewToView:(UIView *)view {
    SJGiveGfitSuccessView *successView = [[NSBundle mainBundle] loadNibNamed:@"SJGiveGfitSuccessView" owner:nil options:nil].lastObject;
    CGRect rect = view.bounds;
    successView.frame = CGRectMake((rect.size.width - KDefaultW)/2, 35, KDefaultW, KDefaultH);
    successView.tag = KDefaultTag;
    [view addSubview:successView];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [successView hideSuccessViewFromView:view];
    });
}

- (void)hideSuccessViewFromView:(UIView *)view {
    [[view viewWithTag:KDefaultTag] removeFromSuperview];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

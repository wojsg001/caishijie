//
//  SJPresentFlower.h
//  CaiShiJie
//
//  Created by user on 18/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlcok)(BOOL finished, NSInteger finishCount);

@class SJGiftModel;
@interface SJPresentFlower : UIView

@property (nonatomic, strong) SJGiftModel *model;
@property (nonatomic, assign) NSInteger giftCount;
@property (nonatomic, assign) CGRect originFrame;  // 记录原始坐标
@property (nonatomic, assign) NSInteger animCount; // 动画执行到了第几次
@property (nonatomic, assign, getter=isFinished) BOOL finished;

- (void)animateWithCompleteBlock:(CompleteBlcok)completed;
- (void)shakeNumberLabel;
- (void)hidePresentView;

@end

//
//  SJCover.h
//  CaiShiJie
//
//  Created by user on 18/1/17.
//  Copyright © 2018年 user. All rights reserved.
//新增蒙版

#import <UIKit/UIKit.h>
@class SJCover;
@protocol SJCoverdelegate <NSObject>

-(void)coverClick:(SJCover *)cover;

@end

@interface SJCover : UIView

// 显示蒙版
+ (instancetype)show;
// 隐藏蒙板
+ (void)hide;
// 设置浅灰色蒙版
@property(nonatomic,assign)BOOL didBackground;

@property (nonatomic,weak) id<SJCoverdelegate> delegate;

@end

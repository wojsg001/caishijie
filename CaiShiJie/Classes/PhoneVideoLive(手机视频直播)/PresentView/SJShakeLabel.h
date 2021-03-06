//
//  SJShakeLabel.h
//  CaiShiJie
//
//  Created by user on 18/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJShakeLabel : UILabel

/**
 动画时间
 */
@property (nonatomic, assign) NSTimeInterval *duration;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *borderColer;

- (void)startAnimWithDuration:(NSTimeInterval)duration;

@end

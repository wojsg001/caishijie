//
//  SJVideoUserEnterView.h
//  CaiShiJie
//
//  Created by user on 16/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJVideoUserEnterView : UIView

@property (nonatomic, copy) NSString *message;

+ (void)showAnimateToView:(UIView *)view message:(NSString *)message;

@end

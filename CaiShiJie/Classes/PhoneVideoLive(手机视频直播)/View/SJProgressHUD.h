//
//  SJProgressHUD.h
//  CaiShiJie
//
//  Created by user on 18/11/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReloadBlock)();

@interface SJProgressHUD : UIView

@property (nonatomic, copy) ReloadBlock reloadBlock;

+ (void)showLoadingToView:(UIView *)view;
+ (void)hideLoadingFromView:(UIView *)view;
+ (void)showNetworkErrorToView:(UIView *)view reload:(ReloadBlock)reloadBlock;
+ (void)hideNetworkErrorFromView:(UIView *)view;
- (void)setupSubviews;

@end

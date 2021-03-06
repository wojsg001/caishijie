//
//  SJNoWifiView.h
//  CaiShiJie
//
//  Created by user on 18/10/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJNoWifiViewDelegate <NSObject>

- (void)refreshNetwork;

@end

@interface SJNoWifiView : UIView

@property (nonatomic, weak) id<SJNoWifiViewDelegate>delegate;

+ (void)showNoWifiViewToView:(UIView *)view delegate:(id)delegate;
+ (void)hideNoWifiViewFromView:(UIView *)view;

@end

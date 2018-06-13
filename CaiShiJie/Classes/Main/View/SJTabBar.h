//
//  SJTabBar.h
//  CaiShiJie
//
//  Created by user on 16/12/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJTabBar;
@protocol SJTabBarDelegate <NSObject>

@optional
- (void)tabBar:(SJTabBar *)tabBar didClickButton:(NSInteger)index;

@end

@interface SJTabBar : UIView

/**
 items:保存每一个按钮对应tabBarItem模型
 */
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) id<SJTabBarDelegate>delegate;

- (void)setupSelectedWhichOneButton:(NSInteger)index;

@end

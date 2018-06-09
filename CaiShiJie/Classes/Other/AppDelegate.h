//
//  AppDelegate.h
//  CaiShiJie
//
//  Created by user on 15/12/21.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isNetworkReachable;
@property (assign, nonatomic) BOOL isNetworkReachableWiFi;
/**
 * 方法功能：获取AppDelegate的实例
 */
+(AppDelegate*)getAppDelegate;

@end


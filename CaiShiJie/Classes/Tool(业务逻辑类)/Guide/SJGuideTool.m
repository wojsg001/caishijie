//
//  SJGuideTool.m
//  CaiShiJie
//
//  Created by user on 15/12/22.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJGuideTool.h"
#import "SJNewFeatureController.h"
#import "SJTabBarController.h"

#define SJVersionKey @"version"

@implementation SJGuideTool

+ (void)guideRootViewController:(UIWindow *)window {
    // 判断是否有新版本
    // 获取之前的版本
    NSString *oldVersion = [SJUserDefaults objectForKey:SJVersionKey];
    // 获取当前版本
    NSString *verKey = (__bridge NSString *)kCFBundleVersionKey;
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[verKey];
    
    if (![oldVersion isEqualToString:currentVersion]) {
        // 存储新版本
        [SJUserDefaults setObject:currentVersion forKey:SJVersionKey];
        [SJUserDefaults synchronize];
        
        SJNewFeatureController *newFeatureVC = [[SJNewFeatureController alloc] init];
        window.rootViewController = newFeatureVC;
    } else {
        SJTabBarController *tabBarVC = [[SJTabBarController alloc] init];
        window.rootViewController = tabBarVC;
    }
}

@end

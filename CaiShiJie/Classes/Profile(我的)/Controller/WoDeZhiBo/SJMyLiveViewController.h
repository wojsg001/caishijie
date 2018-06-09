//
//  SJMyLiveViewController.h
//  CaiShiJie
//
//  Created by user on 16/1/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJMyLiveViewController : SJBaseViewController

@property (nonatomic, strong) NSString *user_id; // 登录用户id
@property (nonatomic, strong) NSString *target_id; // 直播用户id
@property (nonatomic, strong) NSString *live_id; // 直播id
@property (nonatomic, assign) BOOL isOldLive; // 是否是历史直播

@end

//
//  SJMyLiveViewController.h
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJMyLiveViewController : SJBaseViewController

@property (nonatomic, strong) NSString *user_id; // 登录用户id
@property (nonatomic, strong) NSString *target_id; // 视频用户id
@property (nonatomic, strong) NSString *live_id; // 视频id
@property (nonatomic, assign) BOOL isOldLive; // 是否是历史视频

@end

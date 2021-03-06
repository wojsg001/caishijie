//
//  SJPersonalCenterViewController.h
//  CaiShiJie
//
//  Created by user on 18/9/28.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

typedef enum :NSInteger {
    kCameraMoveDirectionNone,
    kCameraMoveDirectionUp,
    kCameraMoveDirectionDown,
    kCameraMoveDirectionRight,
    kCameraMoveDirectionLeft
} CameraMoveDirection;

@interface SJPersonalInfoModel : NSObject

@property (nonatomic, copy) NSString *user_id; // 登录用户id
@property (nonatomic, copy) NSString *fans_count;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *is_focus;



@end

@interface SJPersonalCenterViewController : SJBaseViewController

@property (nonatomic, copy) NSString *target_id; // 直播用户id

@property (nonatomic, strong) NSString *user_id; // 登录用户id

@property (nonatomic, strong) NSString *live_id; // 直播id
@property (nonatomic, assign) BOOL isOldLive; // 是否是历史直播
@end

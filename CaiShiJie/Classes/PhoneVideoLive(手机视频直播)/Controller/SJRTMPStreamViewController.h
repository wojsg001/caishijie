//
//  SJRTMPStreamViewController.h
//  CaiShiJie
//
//  Created by user on 18/11/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

/**
 用户信息View
 */
@class SJVideoTeacherInfoModel;
@interface SJRTMPUserView : UIView

@property (nonatomic, strong) SJVideoTeacherInfoModel *model;

@end

/**
 直播流控制器
 */
@interface SJRTMPStreamViewController : SJBaseViewController

@property (nonatomic, copy) NSString *targetid;

@end

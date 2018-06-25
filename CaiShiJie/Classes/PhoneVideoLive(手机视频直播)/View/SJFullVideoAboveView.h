//
//  SJFullVideoAboveView.h
//  CaiShiJie
//
//  Created by user on 18/8/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoTeacherInfoModel, SJUserVideoTopView, SJFullVideoGiftView, SJUserInfoView;
@interface SJFullVideoAboveView : UIView

@property (nonatomic, copy) void(^clickExitButtonEventBlock)();
@property (nonatomic, copy) void(^needPushBlock)();
@property (nonatomic, copy) void(^userInfoViewMoreButtonBlock)(UIButton *button);
@property (nonatomic, strong) SJUserVideoTopView *userVideoTopView;
@property (nonatomic, strong) SJFullVideoGiftView *fullVideoGiftView;
@property (nonatomic, strong) SJVideoTeacherInfoModel *model;

@end

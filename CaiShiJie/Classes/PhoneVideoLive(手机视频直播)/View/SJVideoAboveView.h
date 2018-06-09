//
//  SJVideoAboveView.h
//  CaiShiJie
//
//  Created by user on 16/7/25.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoTeacherInfoModel, SJUserVideoTopView, SJUserInfoView;
@interface SJVideoAboveView : UIView

@property (nonatomic, copy) void(^backButtonClickBlock)();
@property (nonatomic, copy) void(^fullButtonClickBlock)();
@property (nonatomic, copy) void(^userInfoViewMoreButtonBlock)(UIButton *button);

@property (nonatomic, strong) UIView *presentBgView;
@property (nonatomic, strong) SJUserVideoTopView *userVideoTopView;
@property (nonatomic, strong) SJVideoTeacherInfoModel *model;

- (void)addPresentBgView;

@end

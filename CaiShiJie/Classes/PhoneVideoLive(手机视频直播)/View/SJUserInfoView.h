//
//  SJUserInfoView.h
//  CaiShiJie
//
//  Created by user on 16/8/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoTeacherInfoModel;
@interface SJUserInfoView : UIView

@property (nonatomic, copy) void(^clickDeleteButtonBlock)();
@property (nonatomic, copy) void(^clickMoreButtonBlock)(UIButton *button);
@property (nonatomic, strong) SJVideoTeacherInfoModel *model;

@end

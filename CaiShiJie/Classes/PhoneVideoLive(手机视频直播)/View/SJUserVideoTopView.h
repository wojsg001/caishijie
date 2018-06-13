//
//  SJUserVideoTopView.h
//  CaiShiJie
//
//  Created by user on 16/7/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoTeacherInfoModel;
@interface SJUserVideoTopView : UIView

@property (nonatomic, copy) void(^clickUserHeadImageBlock)();
@property (nonatomic, copy) void(^clickUserAttentionButtonBlock)(UIButton *button);
@property (nonatomic, strong) SJVideoTeacherInfoModel *model;

@end

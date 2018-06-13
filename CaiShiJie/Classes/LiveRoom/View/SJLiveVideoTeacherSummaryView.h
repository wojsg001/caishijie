//
//  SJLiveVideoTeacherSummaryView.h
//  CaiShiJie
//
//  Created by user on 16/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJNewLiveVideoTeacherModel;
@interface SJLiveVideoTeacherSummaryView : UIView

@property (nonatomic, copy) void(^removePopupViewBlock)();
@property (nonatomic, strong) SJNewLiveVideoTeacherModel *model;

@end

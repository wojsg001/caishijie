//
//  SJPersonalOldLiveHeadView.h
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJPersonalOldLiveHeadView : UIView

@property (nonatomic, copy) void (^liveButtonClickBlock)();
@property (nonatomic, strong) NSDictionary *infoDic;

@end

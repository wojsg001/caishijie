//
//  SJPopupModifyPriceView.h
//  CaiShiJie
//
//  Created by user on 18/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyNeiCan;
@protocol SJPopupModifyPriceViewDelegate <NSObject>

- (void)SJPopupModifyPriceViewRefreshSuperView;

@end

@interface SJPopupModifyPriceView : UIView

@property (nonatomic, strong) IBOutlet UIView *innerView;
@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) SJMyNeiCan *model;

@property (nonatomic, weak) id<SJPopupModifyPriceViewDelegate>delegate;

+ (instancetype)defaultPopupView;

@end

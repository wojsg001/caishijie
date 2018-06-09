//
//  SJPopupModifyServiceDateView.h
//  CaiShiJie
//
//  Created by user on 16/3/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyNeiCan;
@protocol SJPopupModifyServiceDateViewDelegate <NSObject>

- (void)SJPopupModifyServiceDateViewRefreshSuperView;

@end

@interface SJPopupModifyServiceDateView : UIView

@property (nonatomic, strong) IBOutlet UIView *innerView;
@property (nonatomic, weak) UIViewController *parentVC;

@property (nonatomic, strong) SJMyNeiCan *model;

@property (nonatomic, weak) id<SJPopupModifyServiceDateViewDelegate>delegate;

+ (instancetype)defaultPopupView;

@end

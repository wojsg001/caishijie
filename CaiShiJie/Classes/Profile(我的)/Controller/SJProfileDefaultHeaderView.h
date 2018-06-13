//
//  SJProfileDefaultHeaderView.h
//  CaiShiJie
//
//  Created by user on 16/12/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJProfileDefaultHeaderViewDelegate <NSObject>

- (void)didClickLoginButton;
- (void)didClickRegisterButton;

@end

@interface SJProfileDefaultHeaderView : UIView

@property (nonatomic, weak) id<SJProfileDefaultHeaderViewDelegate>delegate;

@end

//
//  SJPhoneVideoFullViewController.h
//  CaiShiJie
//
//  Created by user on 16/8/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJPhoneVideoFullViewControllerDelegate <NSObject>

- (void)fullVideoAboveViewAttentionButtonClicked:(UIButton *)button;
- (void)skipToLoginViewController;
- (void)skipToBuyGoldViewController;
- (void)userInfoViewMoreButtonPressed:(UIButton *)button;

@end

@class SJVideoTeacherInfoModel, SJFullVideoAboveView;
@interface SJPhoneVideoFullViewController : UIViewController

@property (nonatomic, strong) SJFullVideoAboveView *fullVideoAboveView;
@property (nonatomic, strong) SJVideoTeacherInfoModel *model;
@property (nonatomic, strong) UIView *presentBgView;
@property (nonatomic, copy) void(^dismissViewControllerBlock)();

@property (nonatomic, weak) id<SJPhoneVideoFullViewControllerDelegate>delegate;

@end

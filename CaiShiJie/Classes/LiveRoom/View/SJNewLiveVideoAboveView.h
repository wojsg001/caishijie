//
//  SJNewLiveVideoAboveView.h
//  CaiShiJie
//
//  Created by user on 18/9/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJNewLiveVideoAboveView : UIView

@property (nonatomic, copy) void(^liveVideoAboveViewButtonClickedBlock)(UIButton *sender);

- (void)showProgressHUD;
- (void)hideProgressHUD;
- (void)setProgressHUDMessage:(NSString *)message;
- (void)showCenterButton;
- (void)HideCenterButton;
- (void)showCoverPicture;
- (void)HideCoverPicture;
- (void)setCoverPictureWithUrlString:(NSString *)urlString;
- (void)setPlayButtonSelected:(BOOL)isSelected;
- (void)setPlayButtonAndFullButtonHide:(BOOL)isHide;
- (void)addSingleGesture;
- (void)removeSingleGesture;

@end

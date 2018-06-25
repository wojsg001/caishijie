//
//  SJTeacherReferenceDetailCell.h
//  CaiShiJie
//
//  Created by user on 18/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyNeiCan;
@protocol SJTeacherReferenceDetailCellDelegate <NSObject>

- (void)ClickModifyPriceButton;
- (void)ClickModifyServiceDateButton;
- (void)SJTeacherReferenceDetailCellCreateNewReference; // 创建内参
- (void)SJTeacherReferenceDetailAddReference; // 追加内参
- (void)SJTeacherReferenceDetailCellRefreshSuperView; // 刷新父视图

@end

@interface SJTeacherReferenceDetailCell : UIView

@property (nonatomic, strong) SJMyNeiCan *model;

@property (nonatomic, weak) id<SJTeacherReferenceDetailCellDelegate>delegate;

@end

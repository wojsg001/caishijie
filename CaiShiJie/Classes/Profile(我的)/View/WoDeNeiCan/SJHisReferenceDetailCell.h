//
//  SJHisReferenceDetailCell.h
//  CaiShiJie
//
//  Created by user on 18/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyNeiCan;
@protocol SJHisReferenceDetailCellDelegate <NSObject>

- (void)didClickPayButtonWith:(SJMyNeiCan *)model;

@end

@interface SJHisReferenceDetailCell : UIView

@property (nonatomic, strong) SJMyNeiCan *model;

@property (nonatomic, weak) id<SJHisReferenceDetailCellDelegate>delegate;

@end

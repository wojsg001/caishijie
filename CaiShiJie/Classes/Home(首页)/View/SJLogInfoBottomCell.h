//
//  SJLogInfoBottomCell.h
//  CaiShiJie
//
//  Created by user on 16/2/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJLogInfoBottomCellDelegate <NSObject>

- (void)skipToLoginView;
- (void)showReportView; // 显示举报按钮

@end

@class SJLogDetail;
@interface SJLogInfoBottomCell : UITableViewCell

@property (nonatomic, strong) SJLogDetail *logDetail;

@property (nonatomic, weak) id<SJLogInfoBottomCellDelegate>delegate;

@end

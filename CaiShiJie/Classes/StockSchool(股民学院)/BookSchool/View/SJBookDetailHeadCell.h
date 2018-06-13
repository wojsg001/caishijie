//
//  SJBookDetailHeadCell.h
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJBookDetailHead;

typedef void(^HYBExpandBlock)(BOOL isExpand);


@interface SJBookDetailHeadCell : UITableViewCell

@property (nonatomic, copy) HYBExpandBlock expandBlock;

@property (nonatomic, strong) UIButton *startReadButton;
- (void)configCellWithModel:(SJBookDetailHead *)model;

@end

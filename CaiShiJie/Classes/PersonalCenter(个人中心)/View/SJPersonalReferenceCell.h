//
//  SJPersonalReferenceCell.h
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyNeiCan;
@interface SJPersonalReferenceCell : UITableViewCell

@property (nonatomic, strong) SJMyNeiCan *model;
@property (nonatomic, copy) void (^clickedPayButtonBlock)();

@end

//
//  SJVideoSectionTwoCell.h
//  CaiShiJie
//
//  Created by user on 16/7/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoInfoModel;
@interface SJVideoSectionTwoCell : UITableViewCell

@property (nonatomic, strong) SJVideoInfoModel *model;
@property (nonatomic, copy) void (^allBtnClickEventBlock)(NSInteger);

@end

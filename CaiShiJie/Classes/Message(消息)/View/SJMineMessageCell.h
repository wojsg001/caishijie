//
//  SJMineMessageCell.h
//  CaiShiJie
//
//  Created by user on 18/10/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMineMessageModel;
@interface SJMineMessageCell : UITableViewCell

@property (nonatomic, copy) void(^buttonClickedBlock)(UIButton *button);
@property (nonatomic, strong) SJMineMessageModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

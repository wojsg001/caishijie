//
//  SJGiveHongBaoCell.h
//  CaiShiJie
//
//  Created by user on 16/8/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiveHongBaoFrame;
@interface SJGiveHongBaoCell : UITableViewCell

@property (nonatomic, strong) SJGiveHongBaoFrame *giveHongBaoFrame;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

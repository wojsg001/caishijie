//
//  SJPersonalSummaryTwoCell.h
//  CaiShiJie
//
//  Created by user on 16/10/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJPersonalSummaryTwoCell : UITableViewCell

@property (nonatomic, weak) NSArray *contentArray;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

//
//  SJPersonalSummaryOneCell.h
//  CaiShiJie
//
//  Created by user on 16/10/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJPersonalSummaryOneCell : UITableViewCell

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *content;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

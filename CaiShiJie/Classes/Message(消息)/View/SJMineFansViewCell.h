//
//  SJMineFansViewCell.h
//  CaiShiJie
//
//  Created by user on 16/10/17.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMineFansModel;
@interface SJMineFansViewCell : UITableViewCell

@property (nonatomic, strong) SJMineFansModel *model;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

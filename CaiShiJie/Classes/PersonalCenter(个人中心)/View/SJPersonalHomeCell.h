//
//  SJPersonalHomeCell.h
//  CaiShiJie
//
//  Created by user on 18/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJPersonalHomeModel;
@interface SJPersonalHomeCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *teacherInfoDic;
@property (nonatomic, strong) SJPersonalHomeModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

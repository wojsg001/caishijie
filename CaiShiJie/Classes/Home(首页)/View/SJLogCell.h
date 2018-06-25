//
//  SJLogCell.h
//  CaiShiJie
//
//  Created by user on 18/2/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJRecommendLogFrame;
@interface SJLogCell : UITableViewCell

@property (nonatomic, strong) SJRecommendLogFrame *logFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

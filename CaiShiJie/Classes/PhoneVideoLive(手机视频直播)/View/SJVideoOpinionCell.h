//
//  SJVideoOpinionCell.h
//  CaiShiJie
//
//  Created by user on 16/7/27.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoOpinionVM;
@interface SJVideoOpinionCell : UITableViewCell

@property (nonatomic, strong) SJVideoOpinionVM *videoOpinionVM;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

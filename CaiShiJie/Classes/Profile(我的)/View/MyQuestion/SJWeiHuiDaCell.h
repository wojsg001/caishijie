//
//  SJWeiHuiDaCell.h
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJWeiHuiDaFrame;
@interface SJWeiHuiDaCell : UITableViewCell

@property (nonatomic, strong) SJWeiHuiDaFrame *questionModelF;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

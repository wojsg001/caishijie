//
//  SJYiJingHuiDaCell.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJYiJingHuiDaFrame;
@interface SJYiJingHuiDaCell : UITableViewCell

// 评价按钮
//@property (nonatomic, strong) UIButton *assessBtn;

@property (nonatomic, strong) SJYiJingHuiDaFrame *YiJingHuiDaFrame;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

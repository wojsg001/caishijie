//
//  SJQuestionDetailCell.h
//  CaiShiJie
//
//  Created by user on 16/7/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJQuestionDetailFrame;
@interface SJQuestionDetailCell : UITableViewCell

@property (nonatomic, strong) SJQuestionDetailFrame *questionDetailFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

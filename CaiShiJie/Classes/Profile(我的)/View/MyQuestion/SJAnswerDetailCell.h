//
//  SJAnswerDetailCell.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJAnswerDetailFrame;
@interface SJAnswerDetailCell : UITableViewCell

@property (nonatomic,copy)SJAnswerDetailFrame *answerDetailFrame;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

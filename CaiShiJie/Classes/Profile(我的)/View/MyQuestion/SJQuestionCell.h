//
//  SJQuestionCell.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJQuestionFrame;
@interface SJQuestionCell : UITableViewCell

@property (nonatomic, strong) UIButton *answerBtn;
@property (nonatomic, strong) SJQuestionFrame *questionModelF;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

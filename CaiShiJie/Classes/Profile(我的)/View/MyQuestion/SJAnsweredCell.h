//
//  SJAnsweredCell.h
//  CaiShiJie
//
//  Created by user on 18/1/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJAnswerFrame;
@interface SJAnsweredCell : UITableViewCell

@property (nonatomic, strong) SJAnswerFrame *answerModelF;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

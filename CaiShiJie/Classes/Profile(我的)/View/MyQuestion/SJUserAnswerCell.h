//
//  SJUserAnswerCell.h
//  CaiShiJie
//
//  Created by user on 18/1/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJUserAnswerFrame;
@interface SJUserAnswerCell : UITableViewCell

@property (nonatomic, strong) SJUserAnswerFrame *answerModelF;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

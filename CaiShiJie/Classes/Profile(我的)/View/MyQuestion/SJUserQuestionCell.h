//
//  SJUserQuestionCell.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJUserQuestionFrame;
@interface SJUserQuestionCell : UITableViewCell

@property (nonatomic, strong) SJUserQuestionFrame *questionModelF;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

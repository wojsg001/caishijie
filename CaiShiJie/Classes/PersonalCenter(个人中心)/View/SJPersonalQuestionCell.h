//
//  SJPersonalQuestionCell.h
//  CaiShiJie
//
//  Created by user on 16/10/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJPersonalQuestionFrame;
@interface SJPersonalQuestionCell : UITableViewCell

@property (nonatomic, strong) SJPersonalQuestionFrame *modelFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

//
//  SJMyIssueCell.h
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyIssueMessageFrame;
@interface SJMyIssueCell : UITableViewCell

@property (nonatomic, strong) SJMyIssueMessageFrame *messageF;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

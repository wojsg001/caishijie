//
//  SJChatMessageCell.h
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJChatMessageModel;
@interface SJChatMessageCell : UITableViewCell

@property (nonatomic, strong) SJChatMessageModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

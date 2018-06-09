//
//  SJVideoInteractiveCell.h
//  CaiShiJie
//
//  Created by user on 16/11/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoInteractiveModel;
@interface SJVideoInteractiveCell : UITableViewCell

@property (nonatomic, strong) SJVideoInteractiveModel *model;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

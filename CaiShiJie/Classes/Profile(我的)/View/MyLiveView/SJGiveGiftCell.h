//
//  SJGiveGiftCell.h
//  CaiShiJie
//
//  Created by user on 16/3/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiveGiftFrame;
@interface SJGiveGiftCell : UITableViewCell

@property (nonatomic, strong) SJGiveGiftFrame *giveGiftFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

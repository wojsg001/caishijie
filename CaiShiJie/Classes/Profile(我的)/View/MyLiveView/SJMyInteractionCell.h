//
//  SJMyInteractionCell.h
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyInteractionMessageFrame;
@interface SJMyInteractionCell : UITableViewCell

@property (nonatomic, strong) UIButton * bgBtn;
@property (nonatomic, strong) SJMyInteractionMessageFrame *messageF;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

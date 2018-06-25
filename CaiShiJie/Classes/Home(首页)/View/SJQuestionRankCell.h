//
//  SJQuestionRankCell.h
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJQuestionRankCell : UITableViewCell

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UILabel *sortLabel;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *questionCountLabel;
@property (nonatomic, strong) UIButton *moreButton;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

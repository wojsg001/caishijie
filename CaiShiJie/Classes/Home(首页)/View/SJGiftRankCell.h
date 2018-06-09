//
//  SJGiftRankCell.h
//  CaiShiJie
//
//  Created by user on 16/4/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJGiftRankCell : UITableViewCell

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UILabel *sortLabel;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIImageView *headImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *giftIconView;
@property (nonatomic, strong) UILabel *giftCountLabel;
@property (nonatomic, strong) UIButton *sendButton;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

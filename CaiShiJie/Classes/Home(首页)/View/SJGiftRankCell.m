//
//  SJGiftRankCell.m
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGiftRankCell.h"
#import "Masonry.h"

@implementation SJGiftRankCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJGiftRankCell";
    SJGiftRankCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[SJGiftRankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initSubViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)initSubViews
{
    WS(weakSelf);
    _leftView = [[UIView alloc] init];
    _leftView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_leftView];
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(45);
    }];
    
    _sortLabel = [[UILabel alloc] init];
    _sortLabel.font = [UIFont systemFontOfSize:15];
    _sortLabel.textColor = RGB(153, 153, 153);
    [_leftView addSubview:_sortLabel];
    [_sortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.leftView);
    }];
    
    _rightView = [[UIView alloc] init];
    _rightView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.equalTo(weakSelf.leftView.mas_right).offset(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
    
    _headImgView = [[UIImageView alloc] init];
    _headImgView.layer.cornerRadius = 25/2;
    _headImgView.layer.masksToBounds = YES;
    [_rightView addSubview:_headImgView];
    [_headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.rightView);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(25);
        make.height.mas_equalTo(25);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = RGB(68, 68, 68);
    [_rightView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headImgView.mas_right).offset(10);
        make.centerY.mas_equalTo(weakSelf.rightView);
    }];
    
    _giftIconView = [[UIImageView alloc] init];
    _giftIconView.image = [UIImage imageNamed:@"rank_gift_icon2"];
    [_rightView addSubview:_giftIconView];
    [_giftIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.rightView);
    }];
    
    _giftCountLabel = [[UILabel alloc] init];
    _giftCountLabel.font = [UIFont systemFontOfSize:15];
    _giftCountLabel.textColor = RGB(68, 68, 68);
    [_rightView addSubview:_giftCountLabel];
    [_giftCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.giftIconView.mas_right).offset(8);
        make.centerY.mas_equalTo(weakSelf.rightView);
    }];
    
    _sendButton = [[UIButton alloc] init];
    [_sendButton setImage:[UIImage imageNamed:@"rank_gift_icon1"] forState:UIControlStateNormal];
    [_rightView addSubview:_sendButton];
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(weakSelf.rightView);
    }];
}

@end

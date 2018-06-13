//
//  SJQuestionRankCell.m
//  CaiShiJie
//
//  Created by user on 16/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJQuestionRankCell.h"
#import "Masonry.h"

@interface SJQuestionRankCell ()

@end

@implementation SJQuestionRankCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJQuestionRankCell";
    SJQuestionRankCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[SJQuestionRankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = RGB(68, 68, 68);
    [_rightView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.rightView);
    }];
    
    _questionCountLabel = [[UILabel alloc] init];
    _questionCountLabel.font = [UIFont systemFontOfSize:15];
    _questionCountLabel.textColor = RGB(68, 68, 68);
    [_rightView addSubview:_questionCountLabel];
    [_questionCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.rightView);
    }];
    
    _moreButton = [[UIButton alloc] init];
    [_moreButton setImage:[UIImage imageNamed:@"rank_ask_icon"] forState:UIControlStateNormal];
    [_rightView addSubview:_moreButton];
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(weakSelf.rightView);
    }];
}

@end

//
//  SJHomeEliteTableViewCell.m
//  CaiShiJie
//
//  Created by Alan on 2018/7/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHomeEliteTableViewCell.h"

@implementation SJHomeEliteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImg = [[UIImageView alloc] init];
        [self addSubview:_headImg];
        
        [_headImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).with.offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(80);
        }];
        
        _nameLB = [[UILabel alloc] init];
        _nameLB.font = [UIFont systemFontOfSize:14];
        [self addSubview:_nameLB];
        
        [_nameLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImg.mas_right).with.offset(10);
            make.top.equalTo(self).with.offset(5);
        }];
        
        _contentLB = [[UILabel alloc] init];
        _contentLB.font = [UIFont systemFontOfSize:14];
        _contentLB.numberOfLines = 0;
        [self addSubview:_contentLB];
        
        [_contentLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImg.mas_right).with.offset(10);
            make.top.equalTo(_nameLB.mas_bottom).with.offset(5);
            make.right.equalTo(self).with.offset(-80);
            make.height.mas_equalTo(40);
        }];
        
        _fansLB = [[UILabel alloc] init];
        _fansLB.font = [UIFont systemFontOfSize:14];
        [self addSubview:_fansLB];
        
        [_fansLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImg.mas_right).with.offset(10);
            make.top.equalTo(_contentLB.mas_bottom).with.offset(5);
            make.width.mas_equalTo(80);
        }];
        
        _questionLB = [[UILabel alloc] init];
        _questionLB.font = [UIFont systemFontOfSize:14];
        [self addSubview:_questionLB];
        
        [_questionLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fansLB.mas_right).with.offset(20);
            make.top.equalTo(_contentLB.mas_bottom).with.offset(5);
        }];
        
        _starBtn = [[UIButton alloc] init];
        [_starBtn setTitle:@"关注" forState:UIControlStateNormal];
        [_starBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _starBtn.layer.cornerRadius = 5;
        _starBtn.layer.masksToBounds = YES;
        _starBtn.layer.borderColor = UIColor.lightGrayColor.CGColor;
        _starBtn.layer.borderWidth = 1;
        [self addSubview:_starBtn];
        
        [_starBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(5);
            make.right.equalTo(self).with.offset(-20);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(60);
        }];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  SJMineFansViewCell.m
//  CaiShiJie
//
//  Created by user on 16/10/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMineFansViewCell.h"
#import "SJMineFansModel.h"

@interface SJMineFansViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nickNameLabel;

@end

@implementation SJMineFansViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJMineFansViewCell";
    SJMineFansViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJMineFansViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.layer.cornerRadius = 5.0f;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.image = [UIImage imageNamed:@"live_teacher1"];
    [self.contentView addSubview:_iconImageView];
    
    _nickNameLabel = [[UILabel alloc] init];
    _nickNameLabel.text = @"散户哨兵";
    _nickNameLabel.textColor = [UIColor colorWithHexString:@"#646464" withAlpha:1];
    _nickNameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_nickNameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.width.height.mas_equalTo(35);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (void)setModel:(SJMineFansModel *)model {
    _model = model;
    
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    _nickNameLabel.text = _model.nickname;
}

@end

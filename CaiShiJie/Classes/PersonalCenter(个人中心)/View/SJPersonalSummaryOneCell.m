//
//  SJPersonalSummaryOneCell.m
//  CaiShiJie
//
//  Created by user on 16/10/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalSummaryOneCell.h"
#import "UIColor+helper.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"

@interface SJPersonalSummaryOneCell ()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation SJPersonalSummaryOneCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJPersonalSummaryOneCell";
    SJPersonalSummaryOneCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJPersonalSummaryOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 初始化子视图
        [self initChildView];
    }
    return self;
}

- (void)initChildView {
    _leftLine = [[UIView alloc] init];
    _leftLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.contentView addSubview:_leftLine];
    [_leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(0.5);
    }];
    
    _rightLine = [[UIView alloc] init];
    _rightLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.contentView addSubview:_rightLine];
    [_rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(0.5);
    }];
    
    _leftLabel = [[UILabel alloc] init];
    _leftLabel.textColor = [UIColor colorWithHexString:@"#b3b3b3" withAlpha:1];
    _leftLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_leftLabel];
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(14);
    }];
    
    _rightLabel = [[UILabel alloc] init];
    _rightLabel.numberOfLines = 0;
    _rightLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    _rightLabel.font = [UIFont systemFontOfSize:14];
    _rightLabel.preferredMaxLayoutWidth = SJScreenW - 140;
    [self.contentView addSubview:_rightLabel];
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(110);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    
    self.hyb_lastViewInCell = self.rightLabel;
    self.hyb_bottomOffsetToCell = 10;
}

- (void)setText:(NSString *)text {
    _text = text;
    _leftLabel.text = _text;
}

- (void)setContent:(NSString *)content {
    _content = content;
    _rightLabel.text = _content;
}

@end

//
//  SJAnswerDetailCell.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnswerDetailCell.h"
#import "SJAnswerDetailFrame.h"
#import "SJAnswerdetailModel.h"
#import "UIImageView+WebCache.h"
#import "TYAttributedLabel.h"

@interface SJAnswerDetailCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *answerLabel;

@end

@implementation SJAnswerDetailCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJAnswerDetailCell";
    SJAnswerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJAnswerDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)initSubViews {
    // 初始化头像视图
    _iconView = [[UIImageView alloc] init];
    _iconView.layer.cornerRadius = 4.0f;
    _iconView.layer.masksToBounds = YES;
    _iconView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_iconView];
    
    // 名字
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = RGB(30, 175, 235);
    _nameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_nameLabel];
    
    // 时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_timeLabel];
    
    // 水平
    _levelLabel = [[UILabel alloc] init];
    _levelLabel.font = [UIFont systemFontOfSize:12];
    _levelLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_levelLabel];
    
    _answerLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_answerLabel];
}

- (void)setAnswerDetailFrame:(SJAnswerDetailFrame *)answerDetailFrame {
    if (_answerDetailFrame != answerDetailFrame) {
        _answerDetailFrame = answerDetailFrame;
    }
    
    [self setData];
    [self setFrame];
}

- (void)setData {
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_answerDetailFrame.answerModel.head_img]] placeholderImage:[UIImage imageNamed:@"news_ask_photo"]];
    _nameLabel.text = _answerDetailFrame.answerModel.nickname;
    _levelLabel.text = _answerDetailFrame.answerModel.level;
    _timeLabel.text = _answerDetailFrame.answerModel.created_at;
    [_answerLabel setTextContainer:_answerDetailFrame.contentTextContainer];
}

- (void)setFrame {
    _iconView.frame = _answerDetailFrame.iconF;
    _nameLabel.frame = _answerDetailFrame.nameF;
    _levelLabel.frame = _answerDetailFrame.honorF;
    _timeLabel.frame = _answerDetailFrame.timeF;
    _answerLabel.frame = _answerDetailFrame.answerF;
}

@end

//
//  SJWeiHuiDaCell.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJWeiHuiDaCell.h"
#import "SJWeiHuiDaModel.h"
#import "SJWeiHuiDaFrame.h"
#import "UIImageView+WebCache.h"
#import "SJWeiHuiDaQuestion.h"
#import "TYAttributedLabel.h"

@interface SJWeiHuiDaCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *questionLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation SJWeiHuiDaCell

#pragma mark - class method

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJWeiHuiDaCell";
    SJWeiHuiDaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJWeiHuiDaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - life cirle method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSubViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)initSubViews
{
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
    
    // 问题
    _questionLabel = [[TYAttributedLabel alloc]init];
    [self.contentView addSubview:_questionLabel];

    // 线条
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = RGB(237, 237, 237);
    [self.contentView addSubview:_lineView];
    
}

- (void)setQuestionModelF:(SJWeiHuiDaFrame *)questionModelF
{
    if (_questionModelF != questionModelF) {
        _questionModelF = questionModelF;
    }
    //设置数据
    [self setAnswerData];
    //设置Frame
    [self setAnswerFrame];
}

- (void)setAnswerData
{
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_questionModelF.questionModel.WeiHuiDaQuestionModel.head_img]] placeholderImage:[UIImage imageNamed:@"attention_photo"]];
    _nameLabel.text = _questionModelF.questionModel.WeiHuiDaQuestionModel.nickname;
    _timeLabel.text = _questionModelF.questionModel.WeiHuiDaQuestionModel.created_at;
    
    if (_questionModelF.questionModel.WeiHuiDaQuestionModel.content.length) {
        [_questionLabel setTextContainer:_questionModelF.contentTextContainer];
    }
}

-(void)setAnswerFrame
{
    _iconView.frame =_questionModelF.iconF;
    _nameLabel.frame = _questionModelF.nameF;
    _timeLabel.frame = _questionModelF.timeF;
    _questionLabel.frame = _questionModelF.questionF;
    _lineView.frame = _questionModelF.lineViewF;

}


@end

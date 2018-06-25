//
//  SJQuestionCell.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJQuestionCell.h"
#import "SJQuestionFrame.h"
#import "SJQuestionModel.h"

#import "UIImageView+WebCache.h"
#import "TYAttributedLabel.h"


@interface SJQuestionCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation SJQuestionCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJQuestionCell";
    SJQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    // 时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_timeLabel];
    
    // 回答按钮
    _answerBtn = [[UIButton alloc] init];
    _answerBtn.layer.cornerRadius = 3;
    _answerBtn.layer.masksToBounds = YES;
    _answerBtn.layer.borderColor = RGB(243, 76, 12).CGColor;
    _answerBtn.layer.borderWidth = 1.0f;
    [_answerBtn setTitle:@"回答" forState:UIControlStateNormal];
    [_answerBtn setTitleColor:RGB(243, 76, 12) forState:UIControlStateNormal];
    _answerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_answerBtn];
    
    // 底部View
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = RGB(245, 245, 248);
    [self.contentView addSubview:_bottomView];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_contentLabel];
}

- (void)setQuestionModelF:(SJQuestionFrame *)questionModelF
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
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_questionModelF.questionModel.head_img]] placeholderImage:[UIImage imageNamed:@"icon"]];
    
    _nameLabel.text = _questionModelF.questionModel.nickname;
    _timeLabel.text = _questionModelF.questionModel.created_at;
    
    if (_questionModelF.questionModel.content.length) {
        [_contentLabel setTextContainer:_questionModelF.contentTextContainer];
    }
}

-(void)setAnswerFrame
{
    _iconView.frame =_questionModelF.iconF;
    _nameLabel.frame = _questionModelF.nameF;
    _timeLabel.frame = _questionModelF.timeF;
    _contentLabel.frame = _questionModelF.contentF;
    _answerBtn.frame = _questionModelF.answerBtnF;
    _bottomView.frame = _questionModelF.bottomViewF;
}


@end

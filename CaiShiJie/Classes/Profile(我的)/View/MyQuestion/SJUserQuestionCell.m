//
//  SJUserQuestionCell.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJUserQuestionCell.h"
#import "SJUserQuestionModel.h"
#import "SJUserQuestionFrame.h"
#import "SJUserQuestionDetail.h"
#import "TYAttributedLabel.h"
#import "UIImageView+WebCache.h"

@interface SJUserQuestionCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) TYAttributedLabel *questionLabel;

@end

@implementation SJUserQuestionCell

#pragma mark - class method

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJUserQuestionCell";
    SJUserQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJUserQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    // 回答人数
    _countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont systemFontOfSize:12];
    _countLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_countLabel];
    
    // 问题
    _questionLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_questionLabel];
    
}

- (void)setQuestionModelF:(SJUserQuestionFrame *)questionModelF
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
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_questionModelF.questionModel.questionDetail.head_img]] placeholderImage:[UIImage imageNamed:@"news_ask_photo"]];
    _nameLabel.text = _questionModelF.questionModel.questionDetail.nickname;
    _timeLabel.text = _questionModelF.questionModel.questionDetail.created_at;
    _countLabel.text = _questionModelF.questionModel.answer_count;
    
    [_questionLabel setTextContainer:_questionModelF.textContainer];
}

-(void)setAnswerFrame
{
    _iconView.frame = _questionModelF.iconF;
    _nameLabel.frame = _questionModelF.nameF;
    _timeLabel.frame = _questionModelF.timeF;
    _countLabel.frame = _questionModelF.countF;
    _questionLabel.frame = _questionModelF.questionF;
}


@end

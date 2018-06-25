//
//  SJAnsweredCell.m
//  CaiShiJie
//
//  Created by user on 18/1/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnsweredCell.h"
#import "SJAnswerModel.h"
#import "SJAnswerFrame.h"
#import "UIImageView+WebCache.h"
#import "TYAttributedLabel.h"

@interface SJAnsweredCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;
@property (nonatomic, strong) UIView *line1View;
@property (nonatomic, strong) TYAttributedLabel *answerLabel;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation SJAnsweredCell

#pragma mark - class method
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJAnsweredCell";
    SJAnsweredCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJAnsweredCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    // 回答人数
    _countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont systemFontOfSize:12];
    _countLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_countLabel];
    
    // 线条一
    _line1View = [[UIView alloc] init];
    _line1View.backgroundColor = RGB(237, 237, 237);
    [self.contentView addSubview:_line1View];
    
    // 底部View
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = RGB(245, 245, 248);
    [self.contentView addSubview:_bottomView];
    
    _contentLabel = [[TYAttributedLabel alloc]init];
    [self.contentView addSubview:_contentLabel];
    
    _answerLabel = [[TYAttributedLabel alloc]init];
    [self.contentView addSubview:_answerLabel];
}

- (void)setAnswerModelF:(SJAnswerFrame *)answerModelF
{
    if (_answerModelF != answerModelF) {
        _answerModelF = answerModelF;
    }
    
    //设置数据
    [self setAnswerData];
    //设置Frame
    [self setAnswerFrame];
}

- (void)setAnswerData
{
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_answerModelF.answerModel.head_img]] placeholderImage:[UIImage imageNamed:@"icon"]];
    
    _nameLabel.text = _answerModelF.answerModel.nickname;
    _countLabel.text = _answerModelF.answerModel.answer_count;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_answerModelF.answerModel.created_at doubleValue]];
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = @"MM-dd hh:mm";
    NSString *dateStr = [formater stringFromDate:date];
    _timeLabel.text = dateStr;
    
    if (_answerModelF.answerModel.content.length) {
        [_contentLabel setTextContainer:_answerModelF.contentTextContainer];
    }
    
    if (_answerModelF.answerModel.answer.length) {
        [_answerLabel setTextContainer:_answerModelF.answerTextContainer];
    }
}

-(void)setAnswerFrame
{
    _iconView.frame =_answerModelF.iconF;
    _nameLabel.frame = _answerModelF.nameF;
    _countLabel.frame = _answerModelF.countF;
    _timeLabel.frame = _answerModelF.timeF;
    _contentLabel.frame = _answerModelF.contentF;
    _line1View.frame = _answerModelF.line1ViewF;
    _answerLabel.frame = _answerModelF.answerF;
    _bottomView.frame = _answerModelF.bottomViewF;
}

@end

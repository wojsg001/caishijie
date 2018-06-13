//
//  SJYiJingHuiDaCell.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJYiJingHuiDaCell.h"
#import "SJYiJingHuiDaModel.h"
#import "SJYiJingHuiDaFrame.h"
#import "SJYiJingHuiDaQuestion.h"
#import "SJYiJingHuiDaAnswer.h"

#import "UIImageView+WebCache.h"
#import "TYAttributedLabel.h"

@interface SJYiJingHuiDaCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *answerLabel;
@property (nonatomic, strong) UIView *line1View;
@property (nonatomic, strong) TYAttributedLabel *questionLabel;
//@property (nonatomic, strong) UIView *line2View;
//@property (nonatomic, strong) UILabel *assessLabel;
@property (nonatomic, strong) UILabel *countLabel;
//@property (nonatomic, strong) UILabel *satisfactionLabel;
//@property (nonatomic, strong) UIImageView *starView;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation SJYiJingHuiDaCell

#pragma mark - class method
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJYiJingHuiDaCell";
    SJYiJingHuiDaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJYiJingHuiDaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    // 水平
    _levelLabel = [[UILabel alloc] init];
    _levelLabel.font = [UIFont systemFontOfSize:12];
    _levelLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_levelLabel];
    
    // 回答
    _answerLabel = [[TYAttributedLabel alloc]init];
    [self.contentView addSubview:_answerLabel];
    
    // 线条一
    _line1View = [[UIView alloc] init];
    _line1View.backgroundColor = RGB(237, 237, 237);
    [self.contentView addSubview:_line1View];
    
    // 问题
    _questionLabel = [[TYAttributedLabel alloc]init];
    [self.contentView addSubview:_questionLabel];
    
    // 回答人数
    _countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont systemFontOfSize:12];
    _countLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_countLabel];
    
//    // 线条二
//    _line2View = [[UIView alloc] init];
//    _line2View.backgroundColor = RGB(237, 237, 237);
//    [self.contentView addSubview:_line2View];
    
//    // 评价按钮
//    _assessBtn = [[UIButton alloc] init];
//    _assessBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    [_assessBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//    [_assessBtn setTitle:@"评价" forState:UIControlStateNormal];
//    [_assessBtn setImage:[UIImage imageNamed:@"news_user_icon"] forState:UIControlStateNormal];
//    _assessBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//    [self.contentView addSubview:_assessBtn];
    
//    // 评价
//    _assessLabel = [[UILabel alloc] init];
//    _assessLabel.font = [UIFont systemFontOfSize:15];
//    _assessLabel.numberOfLines = 0;
//    _assessLabel.textColor = RGB(132, 132, 132);
//    [self.contentView addSubview:_assessLabel];
//    
//    // 满意度
//    _satisfactionLabel = [[UILabel alloc] init];
//    _satisfactionLabel.font = [UIFont systemFontOfSize:12];
//    _satisfactionLabel.textColor = RGB(143, 143, 143);
//    [self.contentView addSubview:_satisfactionLabel];
//    
//    // 星星
//    _starView = [[UIImageView alloc] init];
//    [self.contentView addSubview:_starView];
    
    // 底部View
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = RGB(245, 245, 248);
    [self.contentView addSubview:_bottomView];
    
}

- (void)setYiJingHuiDaFrame:(SJYiJingHuiDaFrame *)YiJingHuiDaFrame
{
    if (_YiJingHuiDaFrame != YiJingHuiDaFrame) {
        _YiJingHuiDaFrame = YiJingHuiDaFrame;
    }
    
    //设置数据
    [self setAnswerData];
    //设置Frame
    [self setAnswerFrame];
}

- (void)setAnswerData
{
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_YiJingHuiDaFrame.YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.head_img]] placeholderImage:[UIImage imageNamed:@"attention_photo"]];
    
    _nameLabel.text = _YiJingHuiDaFrame.YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.nickname;
    _levelLabel.text = _YiJingHuiDaFrame.YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.honor;
    _timeLabel.text = _YiJingHuiDaFrame.YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.created_at;
    
    // 回答
    if (_YiJingHuiDaFrame.YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.content.length) {
        [_answerLabel setTextContainer:_YiJingHuiDaFrame.answerTextContainer];
    }
    
    // 问题
    if (_YiJingHuiDaFrame.YiJingHuiDaModel.YiJingHuiDaQuestionModel.content.length) {
        [_questionLabel setTextContainer:_YiJingHuiDaFrame.contentTextContainer];
    }
    
    // 回答人数
    _countLabel.text = _YiJingHuiDaFrame.YiJingHuiDaModel.answer_count;
    
}

-(void)setAnswerFrame
{
    _iconView.frame = _YiJingHuiDaFrame.iconF;
    _nameLabel.frame = _YiJingHuiDaFrame.nameF;
    _levelLabel.frame = _YiJingHuiDaFrame.levelF;
    _timeLabel.frame = _YiJingHuiDaFrame.timeF;
    _answerLabel.frame = _YiJingHuiDaFrame.answerF;
    _line1View.frame = _YiJingHuiDaFrame.line1ViewF;
    _questionLabel.frame = _YiJingHuiDaFrame.questionF;
    _countLabel.frame = _YiJingHuiDaFrame.countF;
    _bottomView.frame = _YiJingHuiDaFrame.bottomViewF;
}

@end

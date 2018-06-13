//
//  SJUserAnswerCell.m
//  CaiShiJie
//
//  Created by user on 16/1/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserAnswerCell.h"
#import "SJUserAnswerModel.h"
#import "SJUserAnswerFrame.h"
#import "SJUserAnswerDetail.h"
#import "TYAttributedLabel.h"
#import "UIImageView+WebCache.h"

@interface SJUserAnswerCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *answerLabel;
@property (nonatomic, strong) UIView *line1View;

@end

@implementation SJUserAnswerCell

#pragma mark - class method

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJUserAnswerCell";
    SJUserAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJUserAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    // 初始化回答
    _answerLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_answerLabel];
    
    // 线条一
    _line1View = [[UIView alloc] init];
    _line1View.backgroundColor = RGB(237, 237, 237);
    [self.contentView addSubview:_line1View];
}

- (void)setAnswerModelF:(SJUserAnswerFrame *)answerModelF
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
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_answerModelF.answerModel.answerDetail.head_img]] placeholderImage:[UIImage imageNamed:@"news_ask_photo"]];
    _nameLabel.text = _answerModelF.answerModel.answerDetail.nickname;
    _levelLabel.text = _answerModelF.answerModel.answerDetail.honor;
    _timeLabel.text = _answerModelF.answerModel.answerDetail.created_at;
    
    [_answerLabel setTextContainer:_answerModelF.textContainer];
}

-(void)setAnswerFrame
{
    _iconView.frame =_answerModelF.iconF;
    _nameLabel.frame = _answerModelF.nameF;
    _levelLabel.frame = _answerModelF.levelF;
    _timeLabel.frame = _answerModelF.timeF;
    _answerLabel.frame = _answerModelF.answerF;
    _line1View.frame = _answerModelF.line1ViewF;
}


@end

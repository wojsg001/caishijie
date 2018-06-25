//
//  SJPersonalQuestionCell.m
//  CaiShiJie
//
//  Created by user on 18/10/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalQuestionCell.h"
#import "TYAttributedLabel.h"
#import "SJPersonalQuestionFrame.h"
#import "SJPersonalQuestionModel.h"

@interface SJPersonalQuestionCell ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) TYAttributedLabel *questionLabel;
@property (nonatomic, strong) TYAttributedLabel *answerLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *honourLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation SJPersonalQuestionCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJPersonalQuestionCell";
    SJPersonalQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJPersonalQuestionCell"];
    if (!cell) {
        cell = [[SJPersonalQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f8" withAlpha:1];
    [self.contentView addSubview:_topView];
    
    _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index_ask_icon"]];
    [self.contentView addSubview:_icon];
    
    _questionLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_questionLabel];
    
    _answerLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_answerLabel];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.contentView addSubview:_lineView];
    
    _headImageView = [[UIImageView alloc] init];
    _headImageView.layer.cornerRadius = 25/2;
    _headImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    _honourLabel = [[UILabel alloc] init];
    _honourLabel.textColor = [UIColor colorWithHexString:@"#b3b3b3" withAlpha:1];
    _honourLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_honourLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor = [UIColor colorWithHexString:@"#b3b3b3" withAlpha:1];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_timeLabel];
}

- (void)setModelFrame:(SJPersonalQuestionFrame *)modelFrame {
    if (_modelFrame != modelFrame) {
        _modelFrame = modelFrame;
    }
    
    [self setSubViewsData];
    [self setSubViewsFrame];
}

- (void)setSubViewsData {
    if (_modelFrame.model.content) {
        [_questionLabel setTextContainer:_modelFrame.questionTextContainer];
    }
    if (_modelFrame.model.answer.content) {
        [_answerLabel setTextContainer:_modelFrame.answerTextContainer];
    }
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_modelFrame.model.answer.head_img]] placeholderImage:[UIImage imageNamed:@"attention_list_photo"]];
    _nameLabel.text = _modelFrame.model.answer.nickname;
    _honourLabel.text = _modelFrame.model.answer.honnor;
    _timeLabel.text = _modelFrame.model.answer.created_at;
}

- (void)setSubViewsFrame {
    _topView.frame = _modelFrame.topViewFrame;
    _icon.frame = _modelFrame.iconFrame;
    _questionLabel.frame = _modelFrame.questionFrame;
    _answerLabel.frame = _modelFrame.answerFrame;
    _lineView.frame = _modelFrame.lineFrame;
    _headImageView.frame = _modelFrame.headImageFrame;
    _nameLabel.frame = _modelFrame.nicknameFrame;
    _honourLabel.frame = _modelFrame.honourFrame;
    _timeLabel.frame = _modelFrame.timeFrame;
}

@end

//
//  SJQuestionDetailCell.m
//  CaiShiJie
//
//  Created by user on 16/7/11.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJQuestionDetailCell.h"
#import "SJDetailModel.h"
#import "SJQuestionDetailFrame.h"
#import "UIImageView+WebCache.h"
#import "TYAttributedLabel.h"

@interface SJQuestionDetailCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;

@end

@implementation SJQuestionDetailCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJQuestionDetailCell";
    SJQuestionDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJQuestionDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    // 时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_timeLabel];
    
    // 回答人数
    _countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont systemFontOfSize:12];
    _countLabel.textColor = RGB(143, 143, 143);
    [self.contentView addSubview:_countLabel];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:_contentLabel];
}

- (void)setQuestionDetailFrame:(SJQuestionDetailFrame *)questionDetailFrame {
    if (_questionDetailFrame != questionDetailFrame) {
        _questionDetailFrame = questionDetailFrame;
    }
    
    [self setData];
    [self setFrame];
}

- (void)setData {
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_questionDetailFrame.questionDetailModel.head_img]] placeholderImage:[UIImage imageNamed:@"icon"]];
    
    _nameLabel.text = _questionDetailFrame.questionDetailModel.nickname;
    _countLabel.text = _questionDetailFrame.questionDetailModel.answer_count;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_questionDetailFrame.questionDetailModel.created_at doubleValue]];
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = @"MM-dd hh:mm";
    NSString *dateStr = [formater stringFromDate:date];
    _timeLabel.text = dateStr;
    
    [_contentLabel setTextContainer:_questionDetailFrame.contentTextContainer];
}

- (void)setFrame {
    _iconView.frame = _questionDetailFrame.iconF;
    _nameLabel.frame = _questionDetailFrame.nameF;
    _countLabel.frame = _questionDetailFrame.countF;
    _timeLabel.frame = _questionDetailFrame.timeF;
    _contentLabel.frame = _questionDetailFrame.contentF;
}

@end

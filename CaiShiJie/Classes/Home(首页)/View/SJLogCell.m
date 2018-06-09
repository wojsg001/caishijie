//
//  SJLogCell.m
//  CaiShiJie
//
//  Created by user on 16/2/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJLogCell.h"
#import "SJRecommendLog.h"
#import "SJRecommendLogFrame.h"
#import "UIImageView+WebCache.h"


@interface SJLogCell ()

@property (strong, nonatomic) UIImageView *head_imgView;
@property (strong, nonatomic) UILabel *nicknameLabel;
@property (strong, nonatomic) UILabel *honorLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UILabel *summaryLabel;
@property (strong, nonatomic) UIImageView *clicks_img;
@property (strong, nonatomic) UILabel *clicksLabel;
@property (strong, nonatomic) UIView *bottomView;

@end

@implementation SJLogCell

#pragma mark - class method

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJLogCell";
    SJLogCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    _head_imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:_head_imgView];
    
    _nicknameLabel = [[UILabel alloc] init];
    _nicknameLabel.font = [UIFont systemFontOfSize:15];
    _nicknameLabel.textColor = RGB(31, 35, 35);
    [self.contentView addSubview:_nicknameLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGB(128, 128, 128);
    [self.contentView addSubview:_timeLabel];
    
    _honorLabel = [[UILabel alloc] init];
    _honorLabel.font = [UIFont systemFontOfSize:12];
    _honorLabel.textColor = RGB(128, 128, 128);
    [self.contentView addSubview:_honorLabel];
    
    _titleL = [[UILabel alloc] init];
    _titleL.font = [UIFont systemFontOfSize:15];
    _titleL.textColor = RGB(34, 34, 34);
    [self.contentView addSubview:_titleL];
    
    _summaryLabel = [[UILabel alloc] init];
    _summaryLabel.font = [UIFont systemFontOfSize:14];
    _summaryLabel.numberOfLines = 0;
    _summaryLabel.textColor = RGB(128, 128, 128);
    [self.contentView addSubview:_summaryLabel];
    
    _clicks_img = [[UIImageView alloc] init];
    [self.contentView addSubview:_clicks_img];
    
    _clicksLabel = [[UILabel alloc] init];
    _clicksLabel.font = [UIFont systemFontOfSize:11];
    _clicksLabel.textColor = RGB(128, 128, 128);
    [self.contentView addSubview:_clicksLabel];
    
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = RGB(237, 237, 237);
    [self.contentView addSubview:_bottomView];

}

- (void)setLogFrame:(SJRecommendLogFrame *)logFrame
{
    if (_logFrame != logFrame)
    {
        _logFrame = logFrame;
    }
    
    //设置数据
    [self setLogData];
    
    //设置Frame
    [self setLogChildViewFrame];
}

- (void)setLogData
{
    [_head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_logFrame.logModel.head_img]] placeholderImage:[UIImage imageNamed:@"attention_list_photo"]];
    _nicknameLabel.text = _logFrame.logModel.nickname;
    _timeLabel.text = _logFrame.logModel.created_at;
    _honorLabel.text = _logFrame.logModel.honor;
    _titleL.text = _logFrame.logModel.title;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_logFrame.logModel.summary];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    // 设置行间距
    [paragraphStyle setLineSpacing:10];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:14]
                             range:NSMakeRange(0, attributedString.length)];
    _summaryLabel.attributedText = attributedString;
    
    _clicks_img.image = [UIImage imageNamed:@"attention_list_icon"];
    _clicksLabel.text = _logFrame.logModel.clicks;
    
}

- (void)setLogChildViewFrame
{
    _head_imgView.frame = _logFrame.head_imgF;
    _nicknameLabel.frame = _logFrame.nicknameF;
    _honorLabel.frame = _logFrame.honorF;
    _timeLabel.frame = _logFrame.created_atF;
    _titleL.frame = _logFrame.titleF;
    _summaryLabel.frame = _logFrame.summaryF;
    _clicks_img.frame = _logFrame.clicks_imgF;
    _clicksLabel.frame = _logFrame.clicksF;
    _bottomView.frame = _logFrame.bottomViewF;
    
}

@end

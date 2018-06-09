//
//  SJVideoOpinionCell.m
//  CaiShiJie
//
//  Created by user on 16/7/27.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJVideoOpinionCell.h"
#import "TYAttributedLabel.h"
#import "SJVideoOpinionVM.h"
#import "SJVideoOpinionModel.h"
#import "NSString+SJDate.h"

@interface SJVideoOpinionCell ()

@property (nonatomic, strong) UIImageView *headIconImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;

@end

@implementation SJVideoOpinionCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJVideoOpinionCell";
    SJVideoOpinionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJVideoOpinionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.userInteractionEnabled = YES;
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews {
    _headIconImageView = [[UIImageView alloc] init];
    _headIconImageView.layer.cornerRadius = 5;
    _headIconImageView.layer.masksToBounds = YES;
    _headIconImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_headIconImageView];
    
    _backgroundButton = [[UIButton alloc] init];
    [self.contentView addSubview:_backgroundButton];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGB(151, 151, 151);
    [_backgroundButton addSubview:_timeLabel];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    [_backgroundButton addSubview:_contentLabel];
}

- (void)setVideoOpinionVM:(SJVideoOpinionVM *)videoOpinionVM {
    if (_videoOpinionVM != videoOpinionVM) {
        _videoOpinionVM = videoOpinionVM;
    }
    
    [self setOponionData];
    [self setOpinionFrame];
}

- (void)setOponionData {
    [_headIconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_videoOpinionVM.videoOpinionModel.model.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    _timeLabel.text = [NSString dateWithString:_videoOpinionVM.videoOpinionModel.model.created_at];
    
    [_contentLabel setTextContainer:_videoOpinionVM.textContainer];
    [_backgroundButton setBackgroundImage:[UIImage resizableImageWithName:@"backgimg_broadcast"] forState:UIControlStateNormal];
}

- (void)setOpinionFrame {
    _headIconImageView.frame = _videoOpinionVM.headIconFrame;
    _timeLabel.frame = _videoOpinionVM.timeFrame;
    _contentLabel.frame = _videoOpinionVM.contentFrame;
    _backgroundButton.frame = _videoOpinionVM.backgroundFrame;
}

@end

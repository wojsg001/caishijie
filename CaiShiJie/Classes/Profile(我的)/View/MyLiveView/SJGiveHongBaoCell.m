//
//  SJGiveHongBaoCell.m
//  CaiShiJie
//
//  Created by user on 16/8/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGiveHongBaoCell.h"
#import "SJGiveHongBaoFrame.h"
#import "SJGiveGiftModel.h"
#import "SJSenderModel.h"
#import "SJGiftGeterModel.h"
#import "UIImageView+WebCache.h"

@interface SJGiveHongBaoCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *statePictureView;
@property (nonatomic, strong) UIImageView *contentPictureView;
@property (nonatomic, strong) UIButton * bgBtn;

@end

@implementation SJGiveHongBaoCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJGiveHongBaoCell";
    SJGiveHongBaoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJGiveHongBaoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = YES;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    // 初始化头像视图
    _iconView = [[UIImageView alloc] init];
    _iconView.layer.cornerRadius = 5;
    _iconView.layer.masksToBounds = YES;
    _iconView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_iconView];
    
    // 初始化正文背景视图
    _bgBtn = [[UIButton alloc] init];
    [self.contentView addSubview:_bgBtn];
    
    // 时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = RGB(151, 151, 151);
    [_bgBtn addSubview:_timeLabel];
    
    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = RGB(51, 51, 51);
    [_bgBtn addSubview:_titleLabel];
    
    _statePictureView = [[UIImageView alloc] init];
    _statePictureView.hidden = YES;
    _statePictureView.image = [UIImage imageNamed:@"live_hb"];
    _statePictureView.backgroundColor = [UIColor clearColor];
    [_bgBtn addSubview:_statePictureView];
    
    _contentPictureView = [[UIImageView alloc] init];
    _contentPictureView.image = [UIImage imageNamed:@"live_hongbao"];
    _contentPictureView.backgroundColor = [UIColor clearColor];
    [_bgBtn addSubview:_contentPictureView];
}

- (void)setGiveHongBaoFrame:(SJGiveHongBaoFrame *)giveHongBaoFrame {
    if (_giveHongBaoFrame != giveHongBaoFrame) {
        _giveHongBaoFrame = giveHongBaoFrame;
    }
    
    // 设置数据
    [self setSubViewsData];
    // 设置Frame
    [self setSubViewsFrame];
}

- (void)setSubViewsData {
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_giveHongBaoFrame.giveGiftModel.senderModel.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    _timeLabel.text = _giveHongBaoFrame.giveGiftModel.created_at;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_giveHongBaoFrame.giveGiftModel.senderModel.hongbao];
    NSRange range1 = [[attributedString string] rangeOfString:_giveHongBaoFrame.giveGiftModel.senderModel.nickname];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(18, 126, 171) range:range1];
    NSRange range2 = [[attributedString string] rangeOfString:_giveHongBaoFrame.giveGiftModel.senderModel.giftGeterModel.nickname];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(18, 126, 171) range:range2];
    _titleLabel.attributedText = attributedString;
    
    if ([_giveHongBaoFrame.giveGiftModel.senderModel.price floatValue] < KBigHongBao) {
        _statePictureView.hidden = YES;
    } else {
        _statePictureView.hidden = NO;
    }
    
    UIImage *bgImage = [UIImage resizableImageWithName:@"backgimg_broadcast"];
    [_bgBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
}

- (void)setSubViewsFrame {
    _iconView.frame = _giveHongBaoFrame.iconF;
    _timeLabel.frame = _giveHongBaoFrame.timeF;
    _titleLabel.frame = _giveHongBaoFrame.titleF;
    _statePictureView.frame = _giveHongBaoFrame.statePictureF;
    _contentPictureView.frame = _giveHongBaoFrame.contentPictureF;
    _bgBtn.frame = _giveHongBaoFrame.bgBtnF;
}

@end

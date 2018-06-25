//
//  SJGiveGiftCell.m
//  CaiShiJie
//
//  Created by user on 18/3/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGiveGiftCell.h"
#import "SJGiveGiftFrame.h"
#import "SJGiveGiftModel.h"
#import "SJSenderModel.h"
#import "SJGiftGeterModel.h"
#import "UIImageView+WebCache.h"

@interface SJGiveGiftCell ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton * bgBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *pictureView;

@end

@implementation SJGiveGiftCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJGiveGiftCell";
    SJGiveGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[SJGiveGiftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.userInteractionEnabled = YES;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
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
    
    // 内容
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.textColor = RGB(51, 51, 51);
    [_bgBtn addSubview:_contentLabel];
    
    // 图片
    _pictureView = [[UIImageView alloc] init];
    _pictureView.contentMode = UIViewContentModeScaleAspectFill;
    _pictureView.clipsToBounds = YES;
    _pictureView.backgroundColor = [UIColor clearColor];
    [_bgBtn addSubview:_pictureView];
    
}

- (void)setGiveGiftFrame:(SJGiveGiftFrame *)giveGiftFrame
{
    if (_giveGiftFrame != giveGiftFrame)
    {
        _giveGiftFrame = giveGiftFrame;
    }
    
    // 设置数据
    [self setSubViewsData];
    // 设置Frame
    [self setSubViewsFrame];
}

- (void)setSubViewsData
{
    _iconView.image = [UIImage imageNamed:@"live_attitude_icon"];
    _timeLabel.text = _giveGiftFrame.giveGiftModel.created_at;

    NSString *senderStr = _giveGiftFrame.giveGiftModel.senderModel.nickname;
    NSString *geterStr = _giveGiftFrame.giveGiftModel.senderModel.giftGeterModel.nickname;
    NSString *tmpStr = [NSString stringWithFormat:@"%@给%@送",senderStr,geterStr];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:tmpStr];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:15]
                             range:NSMakeRange(0, attributedString.length)];
    NSRange range1 = [[attributedString string] rangeOfString:senderStr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(18, 126, 171) range:range1];
    NSRange range2 = [[attributedString string] rangeOfString:geterStr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(18, 126, 171) range:range2];
    _titleLabel.attributedText = attributedString;
    
    _contentLabel.text = [NSString stringWithFormat:@"礼物：%@",_giveGiftFrame.giveGiftModel.senderModel.item_name];
    
    [_pictureView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://common.csjimg.com/gift/%@",_giveGiftFrame.giveGiftModel.senderModel.item_img]] placeholderImage:[UIImage imageNamed:@"live_gift"]];
    
    UIImage *bgImage = [UIImage resizableImageWithName:@"backgimg_broadcast"];
    [_bgBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
}

- (void)setSubViewsFrame
{
    _iconView.frame = _giveGiftFrame.iconF;
    _timeLabel.frame = _giveGiftFrame.timeF;
    _titleLabel.frame = _giveGiftFrame.titleF;
    _contentLabel.frame = _giveGiftFrame.contentF;
    _pictureView.frame = _giveGiftFrame.pictureF;
    _bgBtn.frame = _giveGiftFrame.bgBtnF;
    
}

@end

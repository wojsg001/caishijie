//
//  SJMyInteractionCell.m
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyInteractionCell.h"
#import "SJMyInteractionMessage.h"
#import "SJMyInteractionMessageFrame.h"
#import "SJInteract.h"
#import "SJOriginal.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "TYAttributedLabel.h"

#define kContentFontSize        14.0f   //内容字体大小
#define kTimeFont [UIFont systemFontOfSize:12]

@interface SJMyInteractionCell ()<TYAttributedLabelDelegate>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;
@property (nonatomic, strong) TYAttributedLabel *originalLabel;

@end

@implementation SJMyInteractionCell

#pragma mark - class method
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJMyInteractionCell";
    SJMyInteractionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJMyInteractionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
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
    
    // 昵称
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = kTimeFont;
    _nameLabel.textColor = RGB(244, 96, 3);
    [_bgBtn addSubview:_nameLabel];
    
    // 时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = kTimeFont;
    _timeLabel.textColor = RGB(157, 157, 157);
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [_bgBtn addSubview:_timeLabel];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    _contentLabel.userInteractionEnabled = NO;
    _contentLabel.delegate = self;
    [_bgBtn addSubview:_contentLabel];
    
    _originalLabel = [[TYAttributedLabel alloc] init];
    _originalLabel.userInteractionEnabled = NO;
    _originalLabel.backgroundColor = RGB(255, 248, 237);
    _originalLabel.layer.borderWidth = 1.0f;
    _originalLabel.layer.borderColor = RGB(249, 234, 213).CGColor;
    _originalLabel.delegate = self;
    [_bgBtn addSubview:_originalLabel];
}

- (void)setMessageF:(SJMyInteractionMessageFrame *)messageF
{
    if (_messageF != messageF) {
        _messageF = messageF;
    }
    
    //设置数据
    [self setMessageData];
    //设置Frame
    [self setMessageFrame];
}

- (void)setMessageData
{
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_messageF.message.interactM.head_img]]];
    _nameLabel.text = _messageF.message.interactM.nickname;
    _timeLabel.text = _messageF.message.interactM.created_at;
    // 内容
    if (_messageF.message.interactM.content) {
        [_contentLabel setTextContainer:_messageF.interactTextContainer];
        _contentLabel.hidden = NO;
    } else {
        _contentLabel.hidden = YES;
    }
    // 回复
    if (_messageF.message.interactM.originalM.content) {
        [_originalLabel setTextContainer:_messageF.originalTextContainer];
        _originalLabel.hidden = NO;
    } else {
        _originalLabel.hidden = YES;
    }
    
    UIImage *bgImage = [UIImage resizableImageWithName:@"backgimg_broadcast"];
    [_bgBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [_bgBtn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
}

- (void)setMessageFrame
{
    _iconView.frame = _messageF.iconF;
    _nameLabel.frame = _messageF.nameF;
    _timeLabel.frame = _messageF.timeF;
    if (_messageF.message.interactM.content) {
        _contentLabel.frame = _messageF.contentF;
    }
    // 如果存在回复
    if (_messageF.message.interactM.originalM.content) {
        _originalLabel.frame = _messageF.textF;
    }
    _bgBtn.frame = _messageF.bgBtnF;
}

#pragma mark - TYAttributedLabelDelegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    NSLog(@"textStorageClickedAtPoint");
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        
        id linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        
        if ([linkStr hasPrefix:@"http"]) {
            [ [ UIApplication sharedApplication] openURL:[ NSURL URLWithString:linkStr]];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:linkStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    } else if ([TextRun isKindOfClass:[TYViewStorage class]]) {
        TYViewStorage *viewStorage = (TYViewStorage *)TextRun;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:[NSURL URLWithString:viewStorage.imgUrl] placeholderImage:[UIImage imageNamed:@"iphone6"]];
        
        MJPhoto *p = [[MJPhoto alloc] init];
        p.url = [NSURL URLWithString:viewStorage.imgUrl];
        p.index = 1;
        p.srcImageView = imageView;
        
        NSArray *arr = @[p];
        
        MJPhotoBrowser *brower = [[MJPhotoBrowser alloc] init];
        brower.photos = arr;
        brower.currentPhotoIndex = 0;
        [brower show];
    }
}

@end

//
//  SJMyIssueCell.m
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyIssueCell.h"
#import "SJMyIssueMessageFrame.h"
#import "SJMyIssueMessage.h"
#import "SJOpinion.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "TYAttributedLabel.h"

#define kContentFontSize        14.0f   //内容字体大小
#define kTimeFont [UIFont systemFontOfSize:12]

@interface SJMyIssueCell ()<TYAttributedLabelDelegate>

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton * bgBtn;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;

@end

@implementation SJMyIssueCell

#pragma mark - class method
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"SJMyIssueCell";
    SJMyIssueCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJMyIssueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    _timeLabel.font = kTimeFont;
    _timeLabel.textColor = RGB(151, 151, 151);
    [_bgBtn addSubview:_timeLabel];
    
    // 内容
    _contentLabel = [[TYAttributedLabel alloc] init];
    _contentLabel.delegate = self;
    [_bgBtn addSubview:_contentLabel];
}

- (void)setMessageF:(SJMyIssueMessageFrame *)messageF
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
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_messageF.message.opinion.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    _timeLabel.text = _messageF.message.opinion.created_at;
    [_contentLabel setTextContainer:_messageF.textContainer];
    
    UIImage *bgImage = [UIImage resizableImageWithName:@"backgimg_broadcast"];
    [_bgBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [_bgBtn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
}

- (void)setMessageFrame
{
    _iconView.frame = _messageF.iconF;
    _timeLabel.frame = _messageF.timeF;
    _contentLabel.frame = _messageF.contentF;
    _bgBtn.frame = _messageF.bgBtnF;
}

#pragma mark - TYAttributedLabelDelegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    NSLog(@"textStorageClickedAtPoint");
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        
        id linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        
        if ([linkStr hasPrefix:@"http"]) {
            [[ UIApplication sharedApplication] openURL:[NSURL URLWithString:linkStr]];
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

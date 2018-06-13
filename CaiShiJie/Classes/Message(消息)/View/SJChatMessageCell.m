//
//  SJChatMessageCell.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJChatMessageCell.h"
#import "SJChatMessageModel.h"
#import "TYAttributedLabel.h"
#import "SDAutoLayout.h"
#import "SDPhotoBrowser.h"

#define kLabelMargin 10.f
#define kLabelTopMargin 8.f

#define kChatCellItemMargin 10.f
#define kChatCellIconImageViewWH 35.f

#define ContentMaxWidth SJScreenW - kChatCellIconImageViewWH * 2 - kChatCellItemMargin * 4 - kLabelMargin * 2

@interface SJChatMessageCell ()<TYAttributedLabelDelegate, SDPhotoBrowserDelegate>

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIImageView *containerBackgroundImageView;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *placeholderImageView;
@property (nonatomic, copy) NSString *imgUrl;

@end

@implementation SJChatMessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJChatMessageCell";
    SJChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SJChatMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.backgroundColor = [UIColor colorWithHexString:@"#cecece" withAlpha:1];
    _timeLabel.layer.cornerRadius = 5.0f;
    _timeLabel.layer.masksToBounds = YES;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLabel];
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.layer.cornerRadius = 5.0f;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    _iconImageView.layer.borderWidth = 0.5f;
    [self.contentView addSubview:_iconImageView];
    
    _container = [[UIView alloc] init];
    _container.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_container];
    
    _containerBackgroundImageView = [[UIImageView alloc] init];
    [_container insertSubview:_containerBackgroundImageView atIndex:0];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    _contentLabel.userInteractionEnabled = YES;
    _contentLabel.delegate = self;
    [_container addSubview:_contentLabel];
    
    [self setupAutoHeightWithBottomView:_container bottomMargin:0];
    // 设置containerBackgroundImageView填充父view
    _containerBackgroundImageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    // 设置时间控件约束
    _timeLabel.sd_layout.topSpaceToView(self.contentView, kChatCellItemMargin)
    .centerXEqualToView(self.contentView)
    .heightIs(20);
}

- (void)setModel:(SJChatMessageModel *)model {
    _model = model;
    
    _iconImageView.frame = CGRectZero;
    _container.frame = CGRectZero;
    _contentLabel.frame = CGRectZero;

    [_iconImageView sd_clearAutoLayoutSettings];
    [_container sd_clearAutoLayoutSettings];
    [_contentLabel sd_clearAutoLayoutSettings];
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.model.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    [self.contentLabel setTextContainer:_model.model.textContainer];
    
    // 根据model设置cell左浮动或者右浮动样式
    [self setMessageOriginWithModel:model];
    
    _contentLabel.sd_resetLayout
    .leftSpaceToView(_container, kLabelMargin)
    .topSpaceToView(_container, kLabelTopMargin)
    .widthIs(_model.model.textWidth)
    .heightIs(_model.model.textContainer.textHeight)
    .minHeightIs(15)
    .minWidthIs(15);
    
    // container以label为rightView宽度自适应
    [_container setupAutoWidthWithRightView:_contentLabel rightMargin:kLabelMargin];
    // container以label为bottomView高度自适应
    [_container setupAutoHeightWithBottomView:_contentLabel bottomMargin:kLabelMargin];
}

- (void)setMessageOriginWithModel:(SJChatMessageModel *)model {
    if (model.messageType == SJMessageTypeSendToOthers) {
        // 发出去的消息设置居右样式
        if (model.model.isShowTime) {
            self.timeLabel.text = model.model.time;
            self.timeLabel.hidden = NO;
            CGSize timeSize = [model.model.time sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
            self.timeLabel.sd_layout.widthIs(timeSize.width + 10);
            self.iconImageView.sd_resetLayout
            .rightSpaceToView(self.contentView, kChatCellItemMargin)
            .topSpaceToView(self.timeLabel, kChatCellItemMargin)
            .widthIs(kChatCellIconImageViewWH)
            .heightIs(kChatCellIconImageViewWH);
        } else {
            self.timeLabel.hidden = YES;
            self.iconImageView.sd_resetLayout
            .rightSpaceToView(self.contentView, kChatCellItemMargin)
            .topSpaceToView(self.contentView, kChatCellItemMargin)
            .widthIs(kChatCellIconImageViewWH)
            .heightIs(kChatCellIconImageViewWH);
        }
        
        _container.sd_resetLayout
        .topEqualToView(self.iconImageView)
        .rightSpaceToView(self.iconImageView, kChatCellItemMargin);
        _containerBackgroundImageView.image = [UIImage resizableImageWithName:@"sixin_07"];
    } else if (model.messageType == SJMessageTypeSendToMe) {
        // 收到的消息设置居左样式
        if (model.model.isShowTime) {
            self.timeLabel.text = model.model.time;
            self.timeLabel.hidden = NO;
            CGSize timeSize = [model.model.time sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
            self.timeLabel.sd_layout.widthIs(timeSize.width + 10);
            self.iconImageView.sd_resetLayout
            .leftSpaceToView(self.contentView, kChatCellItemMargin)
            .topSpaceToView(self.timeLabel, kChatCellItemMargin)
            .widthIs(kChatCellIconImageViewWH)
            .heightIs(kChatCellIconImageViewWH);
        } else {
            self.timeLabel.hidden = YES;
            self.iconImageView.sd_resetLayout
            .leftSpaceToView(self.contentView, kChatCellItemMargin)
            .topSpaceToView(self.contentView, kChatCellItemMargin)
            .widthIs(kChatCellIconImageViewWH)
            .heightIs(kChatCellIconImageViewWH);
        }
        
        _container.sd_resetLayout
        .topEqualToView(self.iconImageView)
        .leftSpaceToView(self.iconImageView, kChatCellItemMargin);
        _containerBackgroundImageView.image = [UIImage resizableImageWithName:@"sixin_03"];
    }
}

#pragma mark - TYAttributedLabelDelegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point {
    if ([TextRun isKindOfClass:[TYViewStorage class]]) {
        TYViewStorage *viewStorage = (TYViewStorage *)TextRun;
        _placeholderImageView = viewStorage.view;
        _imgUrl = viewStorage.imgUrl;
        
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.currentImageIndex = 0;
        browser.sourceImagesContainerView = self.container;
        browser.imageCount = 1;
        browser.delegate = self;
        [browser show];
        [browser hideSaveButtonAndCountLabel];
    }
}

#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    NSURL *url = [NSURL URLWithString:_imgUrl];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    UIImageView *imageView = (UIImageView *)_placeholderImageView;
    return imageView.image;
}

@end

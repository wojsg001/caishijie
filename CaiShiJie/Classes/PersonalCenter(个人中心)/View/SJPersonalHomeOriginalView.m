//
//  SJPersonalHomeOriginalView.m
//  CaiShiJie
//
//  Created by user on 16/10/12.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalHomeOriginalView.h"
#import "SJPersonalHomeModel.h"
#import "SDAutoLayout.h"
#import "TYAttributedLabel.h"
#import "SJPhotoContainerView.h"

#define kMargin 10
#define kHeadImageWH 35
#define ContentMaxWidth SJScreenW - kHeadImageWH - kMargin * 3

@interface SJPersonalHomeOriginalView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;
@property (nonatomic, strong) SJPhotoContainerView *photoView;

@end

@implementation SJPersonalHomeOriginalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#195db0" withAlpha:1];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLabel];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    [self addSubview:_contentLabel];
    
    _photoView = [[SJPhotoContainerView alloc] init];
    [self addSubview:_photoView];
    
    _titleLabel.sd_layout
    .leftEqualToView(self)
    .topEqualToView(self)
    .rightEqualToView(self);
    
    _contentLabel.sd_layout
    .leftEqualToView(self)
    .widthIs(ContentMaxWidth);
    
    _photoView.sd_layout
    .leftEqualToView(self);
}

- (void)setModel:(SJPersonalHomeModel *)model {
    _model = model;
    
    UIView *bottomView;
    if ([_model.types isEqualToString:@"3"] && [_model.item_type isEqualToString:@"22"]) {
        // 原创文章
        _photoView.hidden = YES;
        _titleLabel.sd_layout.heightIs(15);
        _titleLabel.hidden = NO;
        _titleLabel.text = _model.articleModel.title;
        [_contentLabel setTextContainer:[_model.articleModel.textContainer createTextContainerWithTextWidth:ContentMaxWidth]];
        
        _contentLabel.sd_layout
        .topSpaceToView(self.titleLabel, kMargin)
        .heightIs(_model.articleModel.textContainer.textHeight);
        
        bottomView = _contentLabel;
    } else if ([_model.types isEqualToString:@"2"] && [_model.item_type isEqualToString:@"23"]) {
        // 说说
        _titleLabel.sd_layout.heightIs(0);
        _titleLabel.hidden = YES;
        [_contentLabel setTextContainer:[_model.opinionModel.textContainer createTextContainerWithTextWidth:ContentMaxWidth]];
        
        _contentLabel.sd_layout
        .topSpaceToView(self.titleLabel, kMargin)
        .heightIs(_model.opinionModel.textContainer.textHeight);
        
        if (_model.opinionModel.imgs) {
            // 有图片
            _photoView.hidden = NO;
            _photoView.pictureString = _model.opinionModel.imgs;
            
            _photoView.sd_layout.topSpaceToView(self.contentLabel, kMargin);
            bottomView = _photoView;
        } else {
            // 无图片
            _photoView.hidden = YES;
            _photoView.sd_layout.topSpaceToView(self.contentLabel, 0);
            bottomView = _contentLabel;
        }
    } else {
        // 其他类型
        bottomView = _titleLabel;
    }
    
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:15];
}

@end

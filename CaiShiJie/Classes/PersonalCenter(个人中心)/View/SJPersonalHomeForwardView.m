//
//  SJPersonalHomeForwardView.m
//  CaiShiJie
//
//  Created by user on 16/10/12.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalHomeForwardView.h"
#import "SJPersonalHomeModel.h"
#import "SDAutoLayout.h"
#import "TYAttributedLabel.h"
#import "RegexKitLite.h"

#define kMargin 10
#define kHeadImageWH 35
#define ForwardContentMaxWidth SJScreenW - kHeadImageWH * 2 - kMargin * 6
#define AtRegularExpression @"@[\\u4e00-\\u9fa5\\w\\-]+"

@interface SJPersonalHomeForwardView ()

@property (nonatomic, strong) UILabel *forwardLabel;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;

@end

@implementation SJPersonalHomeForwardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4" withAlpha:1];
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _forwardLabel = [[UILabel alloc] init];
    _forwardLabel.isAttributedContent = YES;
    _forwardLabel.textColor = [UIColor colorWithHexString:@"#777777" withAlpha:1];
    _forwardLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_forwardLabel];
    
    _headImageView = [[UIImageView alloc] init];
    _headImageView.image = [UIImage imageNamed:@"pho_mytg"];
    [self addSubview:_headImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#195db0" withAlpha:1];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLabel];
    
    _contentLabel = [[TYAttributedLabel alloc] init];
    _contentLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentLabel];
    
    _forwardLabel.sd_layout
    .leftSpaceToView(self, kMargin)
    .topSpaceToView(self, kMargin)
    .rightSpaceToView(self, kMargin)
    .heightIs(14);
    
    _headImageView.sd_layout
    .leftEqualToView(self.forwardLabel)
    .topSpaceToView(self.forwardLabel, kMargin)
    .widthIs(kHeadImageWH)
    .heightIs(kHeadImageWH);
    
    _titleLabel.sd_layout
    .leftSpaceToView(self.headImageView, kMargin)
    .topEqualToView(self.headImageView)
    .widthIs(ForwardContentMaxWidth);
    
    _contentLabel.sd_layout
    .leftEqualToView(self.titleLabel)
    .widthIs(ForwardContentMaxWidth);
}

- (void)setModel:(SJPersonalHomeModel *)model {
    _model = model;
    
    if ([_model.item_type isEqualToString:@"22"]) {
        // 转发文章
        _titleLabel.sd_layout.heightIs(15);
        _titleLabel.hidden = NO;
        _titleLabel.text = _model.articleModel.title;
        [_contentLabel setTextContainer:[_model.articleModel.textContainer createTextContainerWithTextWidth:ForwardContentMaxWidth]];
        
        _contentLabel.sd_layout
        .topSpaceToView(self.titleLabel, kMargin)
        .heightIs(_model.articleModel.textContainer.textHeight);
        
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.articleModel.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
        NSString *string = [NSString stringWithFormat:@"转发@%@", _model.articleModel.nickname];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        [string enumerateStringsMatchedByRegex:AtRegularExpression usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            if (captureCount > 0) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"444444" withAlpha:1] range:capturedRanges[0]];
            }
        }];
        _forwardLabel.attributedText = attributedString;
    } else if ([_model.item_type isEqualToString:@"21"]
               || [_model.item_type isEqualToString:@"23"]
               || [_model.item_type isEqualToString:@"30"]) {
        // 说说、观点、问股
        _titleLabel.sd_layout.heightIs(0);
        _titleLabel.hidden = YES;
        [_contentLabel setTextContainer:[_model.opinionModel.textContainer createTextContainerWithTextWidth:ForwardContentMaxWidth]];
        
        _contentLabel.sd_layout
        .topSpaceToView(self.titleLabel, 0)
        .heightIs(_model.opinionModel.textContainer.textHeight);
        
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.opinionModel.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
        NSString *string = [NSString stringWithFormat:@"转发@%@", _model.opinionModel.nickname];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        [string enumerateStringsMatchedByRegex:AtRegularExpression usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            if (captureCount > 0) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"444444" withAlpha:1] range:capturedRanges[0]];
            }
        }];
        _forwardLabel.attributedText = attributedString;
    }
    
    [self setupAutoHeightWithBottomViewsArray:@[_headImageView, _contentLabel] bottomMargin:15];
}

@end

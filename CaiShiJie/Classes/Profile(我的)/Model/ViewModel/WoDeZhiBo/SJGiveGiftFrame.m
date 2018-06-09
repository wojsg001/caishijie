//
//  SJGiveGiftFrame.m
//  CaiShiJie
//
//  Created by user on 16/3/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJGiveGiftFrame.h"
#import "SJGiveGiftModel.h"
#import "SJSenderModel.h"
#import "SJGiftGeterModel.h"

#define kContentFontSize        14.0f   //内容字体大小
#define kPadding                10.0f    //控件间隙
#define kEdgeInsetsWidth       10.0f   //内容内边距宽度
#define kBgWidth 15 // 背景图片的小角宽度
#define kImageW 70
#define kImageH 70
#define kTimeFont [UIFont systemFontOfSize:12]

@implementation SJGiveGiftFrame

- (void)setGiveGiftModel:(SJGiveGiftModel *)giveGiftModel
{
    _giveGiftModel = giveGiftModel;
    
    // 头像
    CGFloat iconX = kPadding;
    CGFloat iconY = kPadding;
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 时间
    CGFloat timeX = kEdgeInsetsWidth + kBgWidth;
    CGFloat timeY = kEdgeInsetsWidth;
    CGSize timeSize = [_giveGiftModel.created_at sizeWithAttributes:@{NSFontAttributeName:kTimeFont}];
    _timeF = (CGRect){{timeX,timeY},{SJScreenW/2, timeSize.height}};
    
    // 文字的最大宽度
    float textMaxWidth = SJScreenW - iconW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    
    // 标题
    CGFloat titleX = timeX;
    CGFloat titleY = CGRectGetMaxY(_timeF) + kEdgeInsetsWidth;
    CGSize titleSize = [_giveGiftModel.senderModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _titleF = CGRectMake(titleX, titleY, textMaxWidth, titleSize.height);

    // 内容
    CGFloat contentX = timeX;
    CGFloat contentY = CGRectGetMaxY(_titleF) + kEdgeInsetsWidth;
    CGSize contentSize = [_giveGiftModel.senderModel.item_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _contentF = CGRectMake(contentX, contentY, textMaxWidth, contentSize.height);
    
    // 图片
    CGFloat imgX = timeX;
    CGFloat imgY = CGRectGetMaxY(_contentF) + kEdgeInsetsWidth;
    _pictureF = CGRectMake(imgX, imgY, kImageW, kImageH);
    
    // 计算背景图片的frame
    CGFloat bgX = CGRectGetMaxX(_iconF);
    CGFloat bgY = CGRectGetMinY(_iconF);
    CGFloat bgWidth = SJScreenW - bgX - kPadding;
    CGFloat bgHeight = CGRectGetMaxY(_pictureF) + kEdgeInsetsWidth;
    _bgBtnF = CGRectMake(bgX, bgY, bgWidth, bgHeight);
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_bgBtnF);
}

@end

//
//  SJVideoOpinionVM.m
//  CaiShiJie
//
//  Created by user on 18/7/27.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoOpinionVM.h"
#import "SJVideoOpinionModel.h"
#import "SJParser.h"
#import "TYTextContainer.h"
#import "SJFaceHandler.h"

#define kPadding               10.0f   //控件间隙
#define kEdgeInsetsWidth       10.0f   //内容内边距宽度
#define kBgWidth 15 // 背景图片的小角宽度
#define kHeadImageW 40
#define kHeadImageH 40
@implementation SJVideoOpinionVM

- (void)setVideoOpinionModel:(SJVideoOpinionModel *)videoOpinionModel {
    _videoOpinionModel = videoOpinionModel;
    
    [self handle];
}

#pragma 处理
-(void)handle {
    [self parseAllKeywords];
    [self calculateHegihtAndAttributedString];
    [self calculateCellHegiht];
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *tmpStr = self.videoOpinionModel.model.content;
    if (tmpStr.length) {
        self.emotionArray = [SJParser keywordRangesOfEmotionInString:tmpStr];
        self.fontArray = [SJParser keywordRangesOfFontColorInString:tmpStr];
        self.urlArray = [SJParser keywordRangesOfURLInString:tmpStr];
        self.stockArray = [SJParser keywordRangesOfStockColorInString:tmpStr];
    }
}

#pragma 计算内容高度
- (void)calculateHegihtAndAttributedString {
    NSString *str = [SJParser getHandleString:self.videoOpinionModel.model.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:15];
    textContainer.text = str;
    
    CGFloat imgMaxWidth = _screenWidth - kHeadImageW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情和图片
    for (int i = 0; i < self.emotionArray.count; i++) {
        NSString *tmpStr = self.emotionArray[i];
        NSRange range = [str rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
            NSRange rangeOne = [tmpStr rangeOfString:@"common.csjimg.com/emot/qq"];
            if (rangeOne.location != NSNotFound) {
                // 表情
                NSString *indexStr = tmpStr;
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@"http://common.csjimg.com/emot/qq/" withString:@""];
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@".gif" withString:@""];
                TYImageStorage *imageStorage = [[TYImageStorage alloc] init];
                imageStorage.range = range;
                imageStorage.size = CGSizeMake(20, 20);
                if ([phoneFaceArray containsObject:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]]) {
                    imageStorage.imageName = [NSString stringWithFormat:@"MLEmoji_Expression.bundle/%@", [phoneFaceDictionary objectForKey:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]]];
                } else {
                    imageStorage.imageURL = [NSURL URLWithString:tmpStr];
                }
                [textContainer addTextStorage:imageStorage];
            } else {
                // 图片
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                if ([tmpStr hasSuffix:@".gif"]) {
                    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tmpStr]]];
                } else {
                    [imageView sd_setImageWithURL:[NSURL URLWithString:tmpStr] placeholderImage:[UIImage imageNamed:@"70×70"]];
                }
                
                TYViewStorage *viewStorage = [[TYViewStorage alloc]init];
                viewStorage.range = range;
                viewStorage.view = imageView;
                viewStorage.imgUrl = tmpStr;
                if (!_isRefresh) {
                    viewStorage.size = CGSizeMake(70, 70);
                    [textContainer addTextStorage:viewStorage];
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmpStr]];
                        UIImage *img = [UIImage imageWithData:imgData];
                        CGFloat imgWidth = img.size.width;
                        CGFloat imgHeight = img.size.height;
                        if (imgWidth > imgMaxWidth) {
                            // 计算缩放率
                            CGFloat zoom = imgWidth / imgMaxWidth;
                            self.videoOpinionModel.imgWidth = imgMaxWidth;
                            self.videoOpinionModel.imgHeight = imgHeight / zoom;
                        } else {
                            self.videoOpinionModel.imgWidth = imgWidth;
                            self.videoOpinionModel.imgHeight = imgHeight;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.updateImageSize) {
                                // 回到主线程刷新数据
                                self.updateImageSize(self);
                            }
                        });
                    });
                } else {
                    viewStorage.size = CGSizeMake(self.videoOpinionModel.imgWidth, self.videoOpinionModel.imgHeight);
                    [textContainer addTextStorage:viewStorage];
                }
            }
        }
    }
    
    // url链接
    for (NSDictionary *tmpDic in self.urlArray) {
        NSRange range = [str rangeOfString:tmpDic[@"text"]];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = tmpDic[@"text"];
            linkTextStorage.linkData = tmpDic[@"url"];
            linkTextStorage.underLineStyle=kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }
    
    // 字体颜色
    for (NSString *tmpStr in self.fontArray) {
        NSRange range = [str rangeOfString:tmpStr];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = nil;
            linkTextStorage.linkData = tmpStr;
            linkTextStorage.textColor = [UIColor redColor];
            linkTextStorage.underLineStyle=kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }
    
    // 股票代码
    for (NSString *tmpStr in self.stockArray) {
        NSRange range = [str rangeOfString:tmpStr];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = nil;
            linkTextStorage.linkData = tmpStr;
            linkTextStorage.textColor = RGB(18, 126, 171);
            linkTextStorage.underLineStyle=kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }
    // 文字的最大宽度
    CGFloat textMaxWidth = 0;
    if (_isFullScreen) {
        textMaxWidth = _screenHeight - kHeadImageW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    } else {
        textMaxWidth = _screenWidth - kHeadImageW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    }
    _textContainer = [textContainer createTextContainerWithTextWidth:textMaxWidth];
    _contentHeight = textContainer.textHeight;
    
    self.emotionArray = nil;
    self.urlArray = nil;
    self.fontArray = nil;
    self.stockArray = nil;
}

#pragma 计算cell高度
- (void)calculateCellHegiht {
    // 头像
    CGFloat iconX = kPadding;
    CGFloat iconY = kPadding;
    CGFloat iconW = kHeadImageW;
    CGFloat iconH = kHeadImageH;
    _headIconFrame = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 时间
    CGFloat timeX = kEdgeInsetsWidth + kBgWidth;
    CGFloat timeY = kEdgeInsetsWidth;
    CGSize timeSize = [_videoOpinionModel.model.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _timeFrame = (CGRect){{timeX,timeY},{_screenWidth/2, timeSize.height}};
    
    // 文字的最大宽度
    CGFloat textMaxWidth = 0;
    if (_isFullScreen) {
        textMaxWidth = _screenHeight - kHeadImageW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    } else {
        textMaxWidth = _screenWidth - kHeadImageW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    }
    // 内容
    CGFloat contentX = timeX;
    CGFloat contentY = CGRectGetMaxY(_timeFrame) + kEdgeInsetsWidth;
    _contentFrame = CGRectMake(contentX, contentY, textMaxWidth, _contentHeight);
    
    // 计算背景的frame
    CGFloat bgX = CGRectGetMaxX(_headIconFrame);
    CGFloat bgY = CGRectGetMinY(_headIconFrame);
    CGFloat bgWidth = (_isFullScreen?_screenHeight:_screenWidth) - bgX - kPadding;
    CGFloat bgHeight = CGRectGetMaxY(_contentFrame) + kEdgeInsetsWidth;
    _backgroundFrame = CGRectMake(bgX, bgY, bgWidth, bgHeight);
    
    // 计算cell的高度
    _cellHeight = CGRectGetMaxY(_backgroundFrame);
}

@end

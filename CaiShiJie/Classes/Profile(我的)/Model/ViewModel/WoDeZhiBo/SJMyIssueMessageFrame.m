//
//  SJMyIssueMessageFrame.m
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyIssueMessageFrame.h"
#import "SJMyIssueMessage.h"
#import "SJOpinion.h"
#import "TYTextContainer.h"
#import "SJParser.h"
#import "RegexKitLite.h"
#import "SJFaceHandler.h"

#define kContentFontSize        14.0f   //内容字体大小
#define kPadding                10.0f   //控件间隙
#define kEdgeInsetsWidth        10.0f   //内容内边距宽度
#define kBgWidth 15 // 背景图片的小角宽度
#define kTimeFont [UIFont systemFontOfSize:12]

@implementation SJMyIssueMessageFrame

- (void)setMessage:(SJMyIssueMessage *)message
{
    _message = message;
    // 处理
    [self handle];
}

#pragma 处理
- (void)handle {
    [self parseAllKeywords];
    [self calculateHegihtAndAttributedString];
    [self calculateCellHegiht];
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *tmpStr = _message.opinion.content;
    if (tmpStr.length > 0) {
        self.emotionArray = [SJParser keywordRangesOfEmotionInString:tmpStr];
        self.fontArray = [SJParser keywordRangesOfFontColorInString:tmpStr];
        self.urlArray = [SJParser keywordRangesOfURLInString:tmpStr];
        self.stockArray = [SJParser keywordRangesOfStockColorInString:tmpStr];
    }
}

#pragma 计算内容高度
- (void)calculateHegihtAndAttributedString {
    NSString *str = [SJParser getHandleString:_message.opinion.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:15];
    textContainer.text = str;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 文字的最大宽度
    float textMaxWidth = SJScreenW - 40 - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
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
                        if (imgWidth > textMaxWidth) {
                            // 计算缩放率
                            CGFloat zoom = imgWidth / textMaxWidth;
                            self.message.opinion.imgWidth = textMaxWidth;
                            self.message.opinion.imgHeight = imgHeight / zoom;
                        } else {
                            self.message.opinion.imgWidth = imgWidth;
                            self.message.opinion.imgHeight = imgHeight;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.refreshRowData) {
                                // 回到主线程刷新数据
                                self.refreshRowData(self);
                            }
                        });
                    });
                } else {
                    viewStorage.size = CGSizeMake(self.message.opinion.imgWidth, self.message.opinion.imgHeight);
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
    
    NSString *urlPattern = @"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))";
    [str enumerateStringsMatchedByRegex:urlPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount > 0) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = capturedRanges[0];
            linkTextStorage.text = capturedStrings[1];
            linkTextStorage.linkData = capturedStrings[1];
            linkTextStorage.underLineStyle = kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }];

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
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 时间
    CGFloat timeX = kEdgeInsetsWidth + kBgWidth;
    CGFloat timeY = kEdgeInsetsWidth;
    CGSize timeSize = [_message.opinion.created_at sizeWithAttributes:@{NSFontAttributeName:kTimeFont}];
    _timeF = (CGRect){{timeX,timeY},{SJScreenW/2, timeSize.height}};
    
    CGFloat bgHeight = 60;
    // 内容
    if (_message.opinion.content) {
        // 文字的最大宽度
        float textMaxWidth = SJScreenW - 40 - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
        CGFloat contentX = timeX;
        CGFloat contentY = CGRectGetMaxY(_timeF) + kEdgeInsetsWidth;
        _contentF = CGRectMake(contentX, contentY, textMaxWidth, _contentHeight);
        bgHeight = CGRectGetMaxY(_contentF) + kEdgeInsetsWidth;
    }
    
    // 计算背景图片的frame
    CGFloat bgX = CGRectGetMaxX(_iconF);
    CGFloat bgY = CGRectGetMinY(_iconF);
    CGFloat bgWidth = SJScreenW - bgX - kPadding;
    _bgBtnF = CGRectMake(bgX, bgY, bgWidth, bgHeight);
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_bgBtnF);
}

@end

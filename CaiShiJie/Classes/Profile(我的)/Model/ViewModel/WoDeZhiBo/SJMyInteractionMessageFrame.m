//
//  SJInteractionMessageFrame.m
//  CaiShiJie
//
//  Created by user on 16/1/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJMyInteractionMessageFrame.h"
#import "SJMyInteractionMessage.h"
#import "SJInteract.h"
#import "SJOriginal.h"
#import "TYTextContainer.h"
#import "SJParser.h"
#import "SJFaceHandler.h"

#define kContentFontSize        14.0f   //内容字体大小
#define kPadding                10.0f   //控件间隙
#define kEdgeInsetsWidth        10.0f   //内容内边距宽度
#define kBgWidth 15 // 背景图片的小角宽度
#define kTimeFont [UIFont systemFontOfSize:12]

@implementation SJMyInteractionMessageFrame

- (void)setMessage:(SJMyInteractionMessage *)message
{
    _message = message;
    // 处理
    [self handle];
}

#pragma 处理
-(void)handle {
    [self parseAllKeywords];
    if (_message.interactM.content) {
        // 计算内容高度
        [self calculateInteractHegihtAndAttributedString];
    }
    if (_message.interactM.originalM.content) {
        // 计算回复高度
        [self calculateOriginalHegihtAndAttributedString];
    }
    [self calculateCellHegiht];
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *interactContent = _message.interactM.content;
    if (interactContent != nil) {
        self.interactEmotionArray = [SJParser keywordRangesOfEmotionInString:interactContent];
        self.interactFontArray = [SJParser keywordRangesOfFontColorInString:interactContent];
        self.interactUrlArray = [SJParser keywordRangesOfURLInString:interactContent];
        self.interactStockArray = [SJParser keywordRangesOfStockColorInString:interactContent];
    }
    NSString *originalContent = _message.interactM.originalM.content;
    if (originalContent != nil) {
        self.originalEmotionArray = [SJParser keywordRangesOfEmotionInString:originalContent];
        self.originalFontArray = [SJParser keywordRangesOfFontColorInString:originalContent];
        self.originalUrlArray = [SJParser keywordRangesOfURLInString:originalContent];
        self.originalStockArray = [SJParser keywordRangesOfStockColorInString:originalContent];
    }
}

#pragma 计算内容高度
- (void)calculateInteractHegihtAndAttributedString {
    NSString *str = [SJParser getHandleString:_message.interactM.content];
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
    for (int i = 0; i < self.interactEmotionArray.count; i++) {
        NSString *tmpStr = self.interactEmotionArray[i];
        NSRange range = [str rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
            NSRange rangeOne = [tmpStr rangeOfString:@"common.csjimg.com/emot"];
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
                [imageView sd_setImageWithURL:[NSURL URLWithString:tmpStr] placeholderImage:[UIImage imageNamed:@"70×70"]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                TYViewStorage *viewStorage = [[TYViewStorage alloc]init];
                viewStorage.range = range;
                viewStorage.view = imageView;
                viewStorage.imgUrl = tmpStr;
                viewStorage.size = CGSizeMake(70, 70);
                [textContainer addTextStorage:viewStorage];
            }
        }
    }
    
    // url链接
    for (NSDictionary *tmpDic in self.interactUrlArray) {
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
    for (NSString *tmpStr in self.interactFontArray) {
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
    for (NSString *tmpStr in self.interactStockArray) {
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
    
    _interactTextContainer = [textContainer createTextContainerWithTextWidth:textMaxWidth];
    _interactContentHeight = textContainer.textHeight;
    
    self.interactEmotionArray = nil;
    self.interactUrlArray = nil;
    self.interactFontArray = nil;
    self.interactStockArray = nil;
}

#pragma mark - 计算回复内容高度
- (void)calculateOriginalHegihtAndAttributedString {
    NSString *str = [SJParser getHandleString:_message.interactM.originalM.content];
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
    for (int i = 0; i < self.originalEmotionArray.count; i++) {
        NSString *tmpStr = self.originalEmotionArray[i];
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
                [imageView sd_setImageWithURL:[NSURL URLWithString:tmpStr] placeholderImage:[UIImage imageNamed:@"70×70"]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                TYViewStorage *viewStorage = [[TYViewStorage alloc]init];
                viewStorage.range = range;
                viewStorage.view = imageView;
                viewStorage.imgUrl = tmpStr;
                viewStorage.size = CGSizeMake(70, 70);
                [textContainer addTextStorage:viewStorage];
            }
        }
    }
    
    // url链接
    for (NSDictionary *tmpDic in self.originalUrlArray) {
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
    for (NSString *tmpStr in self.originalFontArray) {
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
    for (NSString *tmpStr in self.originalStockArray) {
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
    
    _originalTextContainer = [textContainer createTextContainerWithTextWidth:textMaxWidth];
    _originalContentHeight = textContainer.textHeight;
    
    self.originalEmotionArray = nil;
    self.originalUrlArray = nil;
    self.originalFontArray = nil;
    self.originalStockArray = nil;
}

#pragma 计算cell高度
- (void)calculateCellHegiht {
    // 头像
    CGFloat iconX = kPadding;
    CGFloat iconY = kPadding;
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = kEdgeInsetsWidth + kBgWidth;
    CGFloat nameY = kEdgeInsetsWidth;
    CGSize nameSize = [_message.interactM.nickname sizeWithAttributes:@{NSFontAttributeName:kTimeFont}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    CGFloat textY = 0;
    CGFloat bgHeight = 0;
    // 文字的最大宽度
    float textMaxWidth = SJScreenW - iconW - kPadding * 2 - kEdgeInsetsWidth * 2 - kBgWidth;
    
    // 内容
    if (_message.interactM.content) {
        CGFloat contentX = nameX;
        CGFloat contentY = CGRectGetMaxY(_nameF) + kEdgeInsetsWidth;
        _contentF = CGRectMake(contentX, contentY, textMaxWidth, _interactContentHeight);
        
        textY = CGRectGetMaxY(_contentF) + kEdgeInsetsWidth;
        bgHeight = CGRectGetMaxY(_contentF) + kEdgeInsetsWidth;
    }
    // 回复
    if (_message.interactM.originalM.content) {
        CGFloat textX = nameX;
        _textF = (CGRect){{textX, textY}, {textMaxWidth, _originalContentHeight}};
        
        bgHeight = CGRectGetMaxY(_textF) + kEdgeInsetsWidth;
    }
    
    // 计算背景图片的frame
    CGFloat bgX = CGRectGetMaxX(_iconF);
    CGFloat bgY = CGRectGetMinY(_iconF);
    CGFloat bgWidth = SJScreenW - bgX - kPadding;
    _bgBtnF = CGRectMake(bgX, bgY, bgWidth, bgHeight);
    
    // 时间
    CGFloat timeY = kPadding;
    CGSize timeSize = [_message.interactM.created_at sizeWithAttributes:@{NSFontAttributeName:kTimeFont}];
    CGFloat timeX = bgWidth - kEdgeInsetsWidth - SJScreenW/2;
    _timeF = (CGRect){{timeX, timeY}, {SJScreenW/2, timeSize.height}};
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_bgBtnF);
}

@end

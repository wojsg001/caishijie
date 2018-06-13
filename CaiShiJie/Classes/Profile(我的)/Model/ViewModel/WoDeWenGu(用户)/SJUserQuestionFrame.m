//
//  SJUserQuestionFrame.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserQuestionFrame.h"
#import "SJUserQuestionModel.h"
#import "SJUserQuestionDetail.h"
#import "SJParser.h"
#import "TYTextContainer.h"
#import "SJFaceHandler.h"

@implementation SJUserQuestionFrame

- (void)setQuestionModel:(SJUserQuestionModel *)questionModel
{
    _questionModel = questionModel;
    
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
    NSString *tmpStr = self.questionModel.questionDetail.content;
    if (tmpStr.length > 0) {
        self.emotionArray = [SJParser keywordRangesOfEmotionInString:tmpStr];
        self.fontArray = [SJParser keywordRangesOfFontColorInString:tmpStr];
        self.urlArray = [SJParser keywordRangesOfURLInString:tmpStr];
        self.stockArray = [SJParser keywordRangesOfStockColorInString:tmpStr];
    }
}

#pragma 计算内容高度
- (void)calculateHegihtAndAttributedString {
    NSString *str = [SJParser getHandleString:self.questionModel.questionDetail.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:15];
    textContainer.text = str;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情
    for (int i = 0; i < self.emotionArray.count; i++) {
        NSString *tmpStr = self.emotionArray[i];
        NSRange range = [str rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
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
    
    _textContainer = [textContainer createTextContainerWithTextWidth:SJScreenW - 20];
    _contentHeight = textContainer.textHeight;
    
    self.emotionArray = nil;
    self.urlArray = nil;
    self.fontArray = nil;
    self.stockArray = nil;
}

#pragma 计算cell高度
- (void)calculateCellHegiht {
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW = 30;
    CGFloat iconH = 30;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 10;
    CGSize nameSize = [_questionModel.questionDetail.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGSize timeSize = [_questionModel.questionDetail.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _timeF = (CGRect){{timeX, timeY}, timeSize};
    
    // 回答人数
    CGFloat countX = nameX;
    CGFloat countY = CGRectGetMaxY(_nameF) + 2;
    CGSize countSize = [_questionModel.answer_count sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _countF = (CGRect){{countX, countY}, countSize};
    
    // 内容
    CGFloat questionX = 10;
    CGFloat questionY = CGRectGetMaxY(_countF) + 10;
    _questionF = (CGRect){{questionX, questionY}, {SJScreenW - 20, _contentHeight}};
    
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_questionF) + 10;
}

@end

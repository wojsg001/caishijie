//
//  SJPersonalQuestionFrame.m
//  CaiShiJie
//
//  Created by user on 16/10/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalQuestionFrame.h"
#import "TYTextContainer.h"
#import "SJPersonalQuestionModel.h"
#import "SJParser.h"
#import "SJFaceHandler.h"

#define QuestionContentMaxWidht SJScreenW - 20 - 18 - 6
#define AnswerContentMaxWidht SJScreenW - 20

@implementation SJPersonalQuestionFrame

- (void)setModel:(SJPersonalQuestionModel *)model {
    _model = model;
    [self handle];
}

#pragma 处理
-(void)handle {
    [self parseAllKeywords];
    if (_model.content) {
        // 计算问题高度
        [self calculateQuestionHegihtAndAttributedString];
    }
    if (_model.answer.content) {
        // 计算回答高度
        [self calculateAnswerHegihtAndAttributedString];
    }
    [self calculateCellHegiht];
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *questionContent = _model.content;
    if (questionContent != nil) {
        self.questionEmotionArray = [SJParser keywordRangesOfEmotionInString:questionContent];
        self.questionFontArray = [SJParser keywordRangesOfFontColorInString:questionContent];
        self.questionUrlArray = [SJParser keywordRangesOfURLInString:questionContent];
        self.questionStockArray = [SJParser keywordRangesOfStockColorInString:questionContent];
    }
    NSString *answerContent = _model.answer.content;
    if (answerContent != nil) {
        self.answerEmotionArray = [SJParser keywordRangesOfEmotionInString:answerContent];
        self.answerFontArray = [SJParser keywordRangesOfFontColorInString:answerContent];
        self.answerUrlArray = [SJParser keywordRangesOfURLInString:answerContent];
        self.answerStockArray = [SJParser keywordRangesOfStockColorInString:answerContent];
    }
}

- (void)calculateQuestionHegihtAndAttributedString {
    NSString *string = [SJParser getHandleString:_model.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:16];
    textContainer.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    textContainer.text = string;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情
    for (int i = 0; i < self.questionEmotionArray.count; i++) {
        NSString *tmpStr = self.questionEmotionArray[i];
        NSRange range = [string rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
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
        }
    }
    
    // url链接
    for (NSDictionary *tmpDic in self.questionUrlArray) {
        NSRange range = [string rangeOfString:tmpDic[@"text"]];
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
    for (NSString *tmpStr in self.questionFontArray) {
        NSRange range = [string rangeOfString:tmpStr];
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
    for (NSString *tmpStr in self.questionStockArray) {
        NSRange range = [string rangeOfString:tmpStr];
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
    
    _questionTextContainer = [textContainer createTextContainerWithTextWidth:QuestionContentMaxWidht];
    _questionContentHeight = textContainer.textHeight;
    
    self.questionEmotionArray = nil;
    self.questionUrlArray = nil;
    self.questionFontArray = nil;
    self.questionStockArray = nil;
}

- (void)calculateAnswerHegihtAndAttributedString {
    NSString *string = [SJParser getHandleString:_model.answer.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:14];
    textContainer.textColor = [UIColor colorWithHexString:@"#737373" withAlpha:1];
    textContainer.text = string;
    
    // 表情
    for (int i = 0; i < self.answerEmotionArray.count; i++) {
        NSString *tmpStr = self.answerEmotionArray[i];
        NSRange range = [string rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
            // 表情
            TYImageStorage *imageStorage = [[TYImageStorage alloc] init];
            imageStorage.imageURL = [NSURL URLWithString:tmpStr];
            imageStorage.range = range;
            imageStorage.size = CGSizeMake(20, 20);
            [textContainer addTextStorage:imageStorage];
        }
    }
    
    // url链接
    for (NSDictionary *tmpDic in self.answerUrlArray) {
        NSRange range = [string rangeOfString:tmpDic[@"text"]];
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
    for (NSString *tmpStr in self.answerFontArray) {
        NSRange range = [string rangeOfString:tmpStr];
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
    for (NSString *tmpStr in self.answerStockArray) {
        NSRange range = [string rangeOfString:tmpStr];
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
    
    _answerTextContainer = [textContainer createTextContainerWithTextWidth:AnswerContentMaxWidht];
    _answerContentHeight = textContainer.textHeight;
    
    self.answerStockArray = nil;
    self.answerFontArray = nil;
    self.answerUrlArray = nil;
    self.answerEmotionArray = nil;
}

#pragma 计算cell高度
- (void)calculateCellHegiht {
    _topViewFrame = CGRectMake(0, 0, SJScreenW, 5);
    
    CGFloat iconX = 10;
    CGFloat iconY = CGRectGetMaxY(_topViewFrame) + 10;
    CGFloat iconW = 18;
    CGFloat iconH = 20;
    _iconFrame = CGRectMake(iconX, iconY, iconW, iconH);
    
    CGFloat questionX = CGRectGetMaxX(_iconFrame) + 6;
    CGFloat questionY = iconY;
    _questionFrame = CGRectMake(questionX, questionY, QuestionContentMaxWidht, _questionContentHeight);
    
    CGFloat answerX = iconX;
    CGFloat answerY = CGRectGetMaxY(_questionFrame) + 10;
    _answerFrame = CGRectMake(answerX, answerY, AnswerContentMaxWidht, _answerContentHeight);
    
    CGFloat lineY = CGRectGetMaxY(_answerFrame) + 10;
    _lineFrame = CGRectMake(0, lineY, SJScreenW, 0.5);
    
    CGFloat headImageX = 15;
    CGFloat headImageY = CGRectGetMaxY(_lineFrame) + 7;
    _headImageFrame = CGRectMake(headImageX, headImageY, 25, 25);
    
    CGFloat nameX = CGRectGetMaxX(_headImageFrame) + 6;
    CGSize nameSize = [_model.answer.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    CGFloat nameY = CGRectGetMidY(_headImageFrame) - nameSize.height/2;
    _nicknameFrame = CGRectMake(nameX, nameY, nameSize.width, nameSize.height);
    
    CGFloat honourX = CGRectGetMaxX(_nicknameFrame) + 9;
    CGSize honourSize = [_model.answer.honnor sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat honourY = CGRectGetMaxY(_nicknameFrame) - honourSize.height;
    _honourFrame = CGRectMake(honourX, honourY, honourSize.width, honourSize.height);
    
    CGSize timeSize = [_model.answer.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    CGFloat timeY = CGRectGetMaxY(_lineFrame) + 12;
    _timeFrame = CGRectMake(timeX, timeY, timeSize.width, timeSize.height);
    
    _cellHeight = CGRectGetMaxY(_headImageFrame) + 7;
}

@end

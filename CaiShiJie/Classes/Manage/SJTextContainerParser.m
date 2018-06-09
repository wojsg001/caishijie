//
//  SJTextContainerParser.m
//  CaiShiJie
//
//  Created by user on 16/8/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTextContainerParser.h"
#import "TYTextContainer.h"
#import "SJParser.h"
#import "SJFaceHandler.h"

@implementation SJTextContainerParser

+ (TYTextContainer *)getTextContainerWithContent:(NSString *)content {
    NSArray *emotionArray;//表情和图片数组
    NSArray *fontArray;//字体数组
    NSArray *urlArray;//网址数组
    NSArray *stockArray;//股票数组
    
    emotionArray = [SJParser keywordRangesOfEmotionInString:content];
    fontArray = [SJParser keywordRangesOfFontColorInString:content];
    urlArray = [SJParser keywordRangesOfURLInString:content];
    stockArray = [SJParser keywordRangesOfStockColorInString:content];
    
    NSString *str = [SJParser getHandleString:content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:15];
    textContainer.text = str;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情和图片
    for (int i = 0; i < emotionArray.count; i++) {
        NSString *tmpStr = emotionArray[i];
        NSRange range = [str rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
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
    for (NSDictionary *tmpDic in urlArray) {
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
    for (NSString *tmpStr in fontArray) {
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
    for (NSString *tmpStr in stockArray) {
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
    
    emotionArray = nil;
    urlArray = nil;
    fontArray = nil;
    stockArray = nil;
    
    return textContainer;
}

@end

//
//  SJPersonalHomeModel.m
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalHomeModel.h"
#import "MJExtension.h"
#import "SJParser.h"
#import "SJFaceHandler.h"
#import "RegexKitLite.h"

@implementation SJPersonalHomeOpinionModel

- (void)setContent:(NSString *)content {
    NSString *tmpString = content;
    tmpString = [tmpString stringByReplacingOccurrencesOfRegex:@"&[a-z;]*" withString:@""];
    tmpString = [tmpString stringByReplacingOccurrencesOfRegex:@"\\s" withString:@""];
    _content = tmpString;
    [self handle];
}

#pragma 处理
-(void)handle {
    [self parseAllKeywords];
    if (self.content) {
        // 计算问题高度
        [self calculateContentHegihtAndAttributedString];
    }
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *content = self.content;
    if (content != nil) {
        self.emotionArray = [SJParser keywordRangesOfEmotionInString:content];
        self.fontArray = [SJParser keywordRangesOfFontColorInString:content];
        self.urlArray = [SJParser keywordRangesOfURLInString:content];
        self.stockArray = [SJParser keywordRangesOfStockColorInString:content];
    }
}

- (void)calculateContentHegihtAndAttributedString {
    NSString *string = [SJParser getHandleString:self.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:15];
    textContainer.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    textContainer.text = string;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情
    for (int i = 0; i < self.emotionArray.count; i++) {
        NSString *tmpStr = self.emotionArray[i];
        NSRange range = [string rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
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
        NSRange range = [string rangeOfString:tmpDic[@"text"]];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = tmpDic[@"text"];
            linkTextStorage.linkData = tmpDic[@"url"];
            linkTextStorage.underLineStyle = kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }
    
    // 字体颜色
    for (NSString *tmpStr in self.fontArray) {
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
    for (NSString *tmpStr in self.stockArray) {
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
    
    _textContainer = textContainer;
    
    self.emotionArray = nil;
    self.urlArray = nil;
    self.fontArray = nil;
    self.stockArray = nil;
}

@end

@implementation SJPersonalHomeArticleModel

- (void)setContent:(NSString *)content {
    NSString *tmpString = content;
    tmpString = [tmpString stringByReplacingOccurrencesOfRegex:@"&[a-z;]*" withString:@""];
    tmpString = [tmpString stringByReplacingOccurrencesOfRegex:@"\\s" withString:@""];
    _content = tmpString;
    [self handle];
}

- (void)setTitle:(NSString *)title {
    _title = [SJParser replaceAllHtmlLabel:title];
}

#pragma 处理
-(void)handle {
    [self parseAllKeywords];
    if (self.content) {
        // 计算问题高度
        [self calculateContentHegihtAndAttributedString];
    }
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *content = self.content;
    if (content != nil) {
        self.emotionArray = [SJParser keywordRangesOfEmotionInString:content];
        self.fontArray = [SJParser keywordRangesOfFontColorInString:content];
        self.urlArray = [SJParser keywordRangesOfURLInString:content];
        self.stockArray = [SJParser keywordRangesOfStockColorInString:content];
    }
}

- (void)calculateContentHegihtAndAttributedString {
    NSString *string = [SJParser getHandleString:self.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:14];
    textContainer.textColor = [UIColor colorWithHexString:@"#666666" withAlpha:1];
    textContainer.text = string;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情
    for (int i = 0; i < self.emotionArray.count; i++) {
        NSString *tmpStr = self.emotionArray[i];
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
    for (NSDictionary *tmpDic in self.urlArray) {
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
    for (NSString *tmpStr in self.fontArray) {
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
    for (NSString *tmpStr in self.stockArray) {
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
    _textContainer = textContainer;
    
    self.emotionArray = nil;
    self.urlArray = nil;
    self.fontArray = nil;
    self.stockArray = nil;
}

@end

@implementation SJPersonalHomeModel

- (void)setItem_data:(NSString *)item_data {
    NSData *jsonData = [item_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    if ([self.item_type isEqualToString:@"21"]
        || [self.item_type isEqualToString:@"23"]
        || [self.item_type isEqualToString:@"30"]) {
        _opinionModel = [SJPersonalHomeOpinionModel objectWithKeyValues:tmpDic];
    } else if ([self.item_type isEqualToString:@"22"]) {
        _articleModel = [SJPersonalHomeArticleModel objectWithKeyValues:tmpDic];
    }
}

- (NSString *)created_at {
    // Tue Mar 10 17:32:22 +0800 2015
    // 字符串转换NSDate
    // _created_at = @"Tue Mar 11 17:48:24 +0800 2015";
    
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    // 设置格式本地化,日期格式字符串需要知道是哪个国家的日期，才知道怎么转换
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_us"];
    
    NSInteger interval = [_created_at integerValue];
    NSDate *created_at = [NSDate dateWithTimeIntervalSince1970:interval];
    
    if ([created_at isThisYear]) { // 今年
        if ([created_at isToday]) { // 今天
            // 计算跟当前时间差距
            NSDateComponents *cmp = [created_at deltaWithNow];
            if (cmp.hour >= 1) {
                return [NSString stringWithFormat:@"%ld小时之前",(long)cmp.hour];
            } else if (cmp.minute > 1) {
                return [NSString stringWithFormat:@"%ld分钟之前",(long)cmp.minute];
            } else {
                return @"刚刚";
            }
        } else if ([created_at isYesterday]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return  [fmt stringFromDate:created_at];
        } else { // 前天
            fmt.dateFormat = @"MM-dd HH:mm";
            return  [fmt stringFromDate:created_at];
        }
    } else { // 不是今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:created_at];
    }
    
    return _created_at;
}

@end

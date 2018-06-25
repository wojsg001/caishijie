//
//  SJParser.m
//  CaiShiJie
//
//  Created by user on 18/7/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJParser.h"

static NSString *fontHtmlRegular = @"<\\s*span\\s+style=[\"']color:(.*?)[\"'].*?>(.*?)<\\/span>";
static NSString *stockHtmlRegular = @"<span[^>]+?data=[\"']?([0-9]{6})[\"']?[^>]*>([^<]+)</span>";
static NSString *iconHtmlRegular = @"<img.*?src=[\"']([^\"]+)(\\.jpg|\\.gif|\\.png|\\.jpeg)[\"'].*?>";
static NSString *urlHtmlRegular = @"<\\s*a\\s+href=[\"|'](.*?)[\"|'].*?>(.*?)<\\/a>";

static NSString *iconRegular = @"(https|http):\\/\\/[^\\s]*\\.(jpg|gif|png|jpeg)";//图片的正则表达式
static NSString *urlRegular = @"((https|http):\\/\\/)[^\\s(\"|')?]+";//网址的正则表达式

@implementation SJParser

+ (NSArray *)keywordRangesOfFontColorInString:(NSString *)string {
    NSArray *matches = [self matcheInString:string regularExpressionWithPattern:fontHtmlRegular];
    NSMutableArray *array = [NSMutableArray array];
    for(NSTextCheckingResult *match in matches) {
        NSString *tmpStr = [string substringWithRange:match.range];
        tmpStr = [self replaceAllHtmlLabel:tmpStr];
        [array addObject:tmpStr];
    }
    return array;
}

+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)string {
    NSArray *matches = [self matcheInString:string regularExpressionWithPattern:iconHtmlRegular];
    NSMutableArray *array = [NSMutableArray array];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:iconRegular options:NSRegularExpressionCaseInsensitive error:nil];
    for(NSTextCheckingResult *match in matches) {
        NSString *tmpStr = [string substringWithRange:match.range];
        NSTextCheckingResult *result = [regex firstMatchInString:tmpStr options:0 range:NSMakeRange(0, [tmpStr length])];
        if (result) {
            NSString *urlStr = [tmpStr substringWithRange:result.range];
            [array addObject:urlStr];
        }
    }
    return array;
}

+ (NSArray *)keywordRangesOfStockColorInString:(NSString *)string {
    NSArray* matches = [self matcheInString:string regularExpressionWithPattern:stockHtmlRegular];
    NSMutableArray *array = [NSMutableArray array];
    for(NSTextCheckingResult* match in matches) {
        NSString *tmpStr = [string substringWithRange:match.range];
        tmpStr = [self replaceAllHtmlLabel:tmpStr];
        [array addObject:tmpStr];
    }
    return array;
}

+ (NSArray *)keywordRangesOfURLInString:(NSString *)string {
    NSArray* matches = [self matcheInString:string regularExpressionWithPattern:urlHtmlRegular];
    NSMutableArray *array = [NSMutableArray array];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegular options:NSRegularExpressionCaseInsensitive error:nil];
    for(NSTextCheckingResult* match in matches) {
        NSString *tmpStr = [string substringWithRange:match.range];
        NSTextCheckingResult *result = [regex firstMatchInString:tmpStr options:0 range:NSMakeRange(0, [tmpStr length])];
        if (result) {
            NSString *urlStr = [tmpStr substringWithRange:result.range];
            tmpStr = [self replaceAllHtmlLabel:tmpStr];
            NSDictionary *dict = @{@"text":tmpStr,@"url":urlStr};
            [array addObject:dict];
        }
    }
    return array;
}

// 得到处理过后的字符串
+ (NSString *)getHandleString:(NSString *)string {
    NSString *str = string;
    NSArray *matches = [self matcheInString:string regularExpressionWithPattern:iconHtmlRegular];
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(NSTextCheckingResult *match in matches) {
        NSString *tmpStr = [string substringWithRange:match.range];
        [tmpArray addObject:tmpStr];
    }
    
    for (int i = 0; i < tmpArray.count; i++) {
        NSRange range = [str rangeOfString:tmpArray[i]];
        if (range.location != NSNotFound) {
            str = [str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"[img%i]",i]];
        }
    }
    // 去除所有html标签
    str = [self replaceAllHtmlLabel:str];
    return str;
}

#pragma mark - 替换所有html标签
+ (NSString *)replaceAllHtmlLabel:(NSString *)str
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@""];
}

#pragma mark - 返回所有查找结果
+(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:string options:0 range:range];
    return matches;
}

@end

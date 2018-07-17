//
//  SJBookDetailHead.m
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBookDetailHead.h"

@implementation SJBookDetailHead

- (void)setSummary:(NSString *)summary
{
    NSString *str = summary;
    str = [str stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"\""];
    str = [str stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"\""];
    str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    str = [SJBookDetailHead replaceAllHtmlLabel:str];
    
    _summary = str;
}

- (NSString *)publication_at
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_publication_at integerValue]];
    return [self dateStringWithDate:date DateFormat:@"yyyy-MM-dd"];
}

- (NSString *)dateStringWithDate:(NSDate *)date DateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    NSString *str = [dateFormatter stringFromDate:date];
    return str ? str : @"";
}

#pragma mark - 替换所有html标签
+ (NSString *)replaceAllHtmlLabel:(NSString *)str
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@""];
}

@end

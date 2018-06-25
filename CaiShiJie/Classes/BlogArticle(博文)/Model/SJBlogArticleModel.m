//
//  SJBlogArticleModel.m
//  CaiShiJie
//
//  Created by user on 18/5/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogArticleModel.h"
#import "RegexKitLite.h"

@implementation SJBlogArticleModel

- (NSString *)created_at
{
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM-dd HH:mm";
    
    NSInteger interval = [_created_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

- (void)setSummary:(NSString *)summary
{
    NSString *tmpString = summary;
    
    tmpString = [tmpString stringByReplacingOccurrencesOfRegex:@"&[a-z;]*" withString:@""];
    tmpString = [tmpString stringByReplacingOccurrencesOfRegex:@"\\s" withString:@""];
    _summary = tmpString;
}

@end

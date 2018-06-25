//
//  SJLogDetail.m
//  CaiShiJie
//
//  Created by user on 18/1/20.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLogDetail.h"

#import "NSDate+MJ.h"

@implementation SJLogDetail

- (NSString *)summary {
    NSString *str = _summary;
    str = [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [SJLogDetail replaceAllHtmlLabel:str];
}

#pragma mark - 替换所有html标签
+ (NSString *)replaceAllHtmlLabel:(NSString *)str {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@""];
}

- (NSString *)created_at {
    // Tue Mar 10 17:32:22 +0800 2015
    // 字符串转换NSDate
    //    _created_at = @"Tue Mar 11 17:48:24 +0800 2015";
    
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
            } else if (cmp.minute > 1){
                return [NSString stringWithFormat:@"%ld分钟之前",(long)cmp.minute];
            } else {
                return @"刚刚";
            }
        } else if ([created_at isYesterday]){ // 昨天
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

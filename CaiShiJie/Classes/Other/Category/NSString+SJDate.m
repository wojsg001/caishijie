//
//  NSString+SJDate.m
//  CaiShiJie
//
//  Created by user on 16/1/26.
//  Copyright © 2016年 user. All rights reserved.
//

#import "NSString+SJDate.h"
#import "NSDate+MJ.h"

@implementation NSString (SJDate)

+ (NSString *)dateWithDate:(NSDate *)date {
      // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_us"];
    if ([date isThisYear]) { // 今年
        if ([date isToday]) { // 今天
            // 计算跟当前时间差距
            NSDateComponents *cmp = [date deltaWithNow];
            NSLog(@"%ld--%ld--%ld",(long)cmp.hour,(long)cmp.minute,(long)cmp.second);
            if (cmp.hour >= 1) {
                return [NSString stringWithFormat:@"%ld小时之前",(long)cmp.hour];
            } else if (cmp.minute > 1){
                return [NSString stringWithFormat:@"%ld分钟之前",(long)cmp.minute];
            } else {
                return @"刚刚";
            }
        } else if ([date isYesterday]){ // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:date];
        } else { // 前天
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:date];
        }
    } else { // 不是今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:date];
        
    }
}

+ (NSString *)dateWithString:(NSString *)dateStr {
    // Tue Mar 10 17:32:22 +0800 2015
    // 字符串转换NSDate
    //    _created_at = @"Tue Mar 11 17:48:24 +0800 2015";
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    // 设置格式本地化,日期格式字符串需要知道是哪个国家的日期，才知道怎么转换
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_us"];
    
    NSInteger interval = [dateStr integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    if ([date isThisYear]) { // 今年
        if ([date isToday]) { // 今天
            // 计算跟当前时间差距
            NSDateComponents *cmp = [date deltaWithNow];
            if (cmp.hour >= 1) {
                return [NSString stringWithFormat:@"%ld小时之前",(long)cmp.hour];
            } else if (cmp.minute > 1){
                return [NSString stringWithFormat:@"%ld分钟之前",(long)cmp.minute];
            } else {
                return @"刚刚";
            }
        } else if ([date isYesterday]){ // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return  [fmt stringFromDate:date];
        } else { // 前天
            fmt.dateFormat = @"MM-dd HH:mm";
            return  [fmt stringFromDate:date];
        }
    } else { // 不是今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:date];
    }
}

@end

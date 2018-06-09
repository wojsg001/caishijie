//
//  NSDate+MJ.m
//  ItcastWeibo
//
//  Created by apple on 14-5-9.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "NSDate+MJ.h"

@implementation NSDate (MJ)
/**
 *  是否为今天
 */
- (BOOL)isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

- (BOOL)isMorning {
    NSCalendar *calender = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *selfCmps = [calender components:unit fromDate:self];
    return
    (selfCmps.hour >= 0) &&
    (selfCmps.minute >= 0) &&
    (selfCmps.hour <= 5) &&
    (selfCmps.minute <= 59);
}

- (BOOL)isAM {
    NSCalendar *calender = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *selfCmps = [calender components:unit fromDate:self];
    return
    (selfCmps.hour >= 6) &&
    (selfCmps.minute >= 0) &&
    (selfCmps.hour <= 11) &&
    (selfCmps.minute <= 59);
}

- (BOOL)isPM {
    NSCalendar *calender = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *selfCmps = [calender components:unit fromDate:self];
    return
    (selfCmps.hour >= 12) &&
    (selfCmps.minute >= 0) &&
    (selfCmps.hour <= 17) &&
    (selfCmps.minute <= 59);
}

- (BOOL)isNight {
    NSCalendar *calender = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *selfCmps = [calender components:unit fromDate:self];
    return
    (selfCmps.hour >= 18) &&
    (selfCmps.minute >= 0) &&
    (selfCmps.hour <= 23) &&
    (selfCmps.minute <= 59);
}

/**
 *  是否为昨天
 */
- (BOOL)isYesterday {
    // 2014-05-01
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    // 2014-04-30
    NSDate *selfDate = [self dateWithYMD];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

- (BOOL)isInSevenDay {
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    NSDate *selfDate = [self dateWithYMD];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day <= 7;
}

- (NSDate *)dateWithYMD {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

/**
 *  是否为今年
 */
- (BOOL)isThisYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year;
}

- (NSDateComponents *)deltaWithNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:self toDate:[NSDate date] options:0];
}

/**
 *  返回一个只有年月日时分的时间
 */
- (NSString *)stringDateWithYMDHM {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyyMMddHHmm";
    return [fmt stringFromDate:self];
}

@end

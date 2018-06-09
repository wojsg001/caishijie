//
//  NSDate+MJ.h
//  ItcastWeibo
//
//  Created by apple on 14-5-9.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MJ)
/**
 *  是否为今天
 */
- (BOOL)isToday;
/**
 *  是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  是否为今年
 */
- (BOOL)isThisYear;

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD;

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)deltaWithNow;

- (BOOL)isMorning;
- (BOOL)isAM;
- (BOOL)isPM;
- (BOOL)isNight;
/**
 *  是在7天内
 */
- (BOOL)isInSevenDay;

/**
 *  返回一个只有年月日时分的时间
 */
- (NSString *)stringDateWithYMDHM;

@end

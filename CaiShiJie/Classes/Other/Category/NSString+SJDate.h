//
//  NSString+SJDate.h
//  CaiShiJie
//
//  Created by user on 16/1/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SJDate)

+ (NSString *)dateWithDate:(NSDate *)date;
+ (NSString *)dateWithString:(NSString *)dateStr;

@end

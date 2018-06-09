//
//  SJMyNeiCan.m
//  CaiShiJie
//
//  Created by user on 15/12/31.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJMyNeiCan.h"

@implementation SJMyNeiCan

- (NSString *)created_at
{
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM-dd HH:mm";

    NSInteger interval = [_created_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

- (NSString *)start_at
{
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSInteger interval = [_start_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

- (NSString *)end_at
{
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSInteger interval = [_end_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

- (NSString *)pay_created_at
{
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM-dd HH:mm";
    
    NSInteger interval = [_pay_created_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

@end

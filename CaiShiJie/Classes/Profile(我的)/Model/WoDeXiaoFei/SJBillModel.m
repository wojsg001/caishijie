//
//  SJBillModel.m
//  CaiShiJie
//
//  Created by user on 18/3/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBillModel.h"

@implementation SJBillModel

- (NSString *)created_at
{
    NSInteger interval = [_created_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    return [format stringFromDate:date];
}

@end

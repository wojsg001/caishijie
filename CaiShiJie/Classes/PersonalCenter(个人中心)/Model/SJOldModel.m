//
//  SJOldModel.m
//  CaiShiJie
//
//  Created by user on 18/1/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJOldModel.h"
#import "NSDate+MJ.h"

@implementation SJOldModel


- (NSString *)created_at
{
    NSInteger interval = [_created_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd"];
    
    return [format stringFromDate:date];
}


@end

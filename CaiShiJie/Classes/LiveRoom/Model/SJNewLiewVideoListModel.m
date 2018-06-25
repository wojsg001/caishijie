//
//  SJNewLiewVideoListModel.m
//  CaiShiJie
//
//  Created by user on 18/9/2.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNewLiewVideoListModel.h"

@implementation SJNewLiewVideoListModel

- (NSString *)start_at {
    NSInteger interval = [_start_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    return [format stringFromDate:date];
}

- (NSString *)end_at {
    NSInteger interval = [_end_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    return [format stringFromDate:date];
}

@end

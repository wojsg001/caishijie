//
//  SJAnswerdetailModel.m
//  CaiShiJie
//
//  Created by user on 18/1/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnswerdetailModel.h"

@implementation SJAnswerdetailModel

- (instancetype)initwithdic:(NSDictionary *)dic {
    if ([super init]) {
        self.answer_count = dic[@"answer_count"];
        self.created_at = dic[@"created_at"];
        NSString *dataStr = dic[@"data"];
        
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionaray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        self.content = dictionaray[@"content"];
        
        self.head_img = dictionaray[@"head_img"];
        self.nickname = dictionaray[@"nickname"];
        NSNumber *level = dictionaray[@"level"];
        NSString *levels = [NSString stringWithFormat:@"%@",level];
        if ([levels isEqualToString:@"10"]) {
            self.level= @"老师";
        } else {
            self.level = @"投资";
        }
    }
    return self;
}

+ (instancetype)modelwithdic:(NSDictionary *)dict {
    return [[self alloc] initwithdic:dict];
}

- (void)setContent:(NSString *)content {
    
    NSString *str = content;
    str = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    _content = [NSString stringWithFormat:@"【回答】：%@", str];
}

- (NSString *)created_at
{
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

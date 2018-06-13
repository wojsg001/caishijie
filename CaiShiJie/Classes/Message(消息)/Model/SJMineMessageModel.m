//
//  SJMineMessageModel.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMineMessageModel.h"
#import "SJParser.h"
#import "SJFaceHandler.h"
#import "RegexKitLite.h"

@implementation SJMineMessageModel

- (void)setContent:(NSString *)content {
    NSString *string;
    if ([self.type isEqualToString:@"30"]) {
        string = [SJParser getHandleString:[NSString stringWithFormat:@"%@:%@", self.nickname, content]];
    } else {
        string = [SJParser getHandleString:content];
    }
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    
    NSArray *emotionArray = [SJParser keywordRangesOfEmotionInString:content];
    for (int i = 0; i < emotionArray.count; i++) {
        NSString *iconUrl = emotionArray[i];
        NSRange range = [string rangeOfString:[NSString stringWithFormat:@"[img%i]", i]];
        if (range.location != NSNotFound) {
            NSRange tmpRange = [iconUrl rangeOfString:@"common.csjimg.com/emot/qq"];
            if (tmpRange.location != NSNotFound) {
                // 表情
                NSString *indexStr = iconUrl;
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@"http://common.csjimg.com/emot/qq/" withString:@""];
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@".gif" withString:@""];
                string = [string stringByReplacingCharactersInRange:range withString:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]];
            } else {
                // 图片
                string = [string stringByReplacingCharactersInRange:range withString:@"[图片]"];
            }
        }
    }
    _content = string;
    
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    // 通过正则匹配表情
    [string enumerateStringsMatchedByRegex:@"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount > 0) {
            NSString *tmpString = capturedStrings[0];
            if ([string isEqualToString:@"[图片]"]) {
                return ;
            }
            
            if ([phoneFaceArray containsObject:tmpString]) {
                NSTextAttachment *imgTextAlignment = [[NSTextAttachment alloc] init];
                imgTextAlignment.image = [UIImage imageNamed:[NSString stringWithFormat:@"MLEmoji_Expression.bundle/%@", [phoneFaceDictionary objectForKey:tmpString]]];
                imgTextAlignment.bounds = CGRectMake(0, -2, 14, 14);
                NSAttributedString *imgAttributed = [NSAttributedString attributedStringWithAttachment:imgTextAlignment];
                NSRange range = [[attributedString string] rangeOfString:tmpString];
                [attributedString replaceCharactersInRange:range withAttributedString:imgAttributed];
            }
        }
    }];
    _contentAttributedString = attributedString;
}

- (void)setCreated_at:(NSString *)created_at {
    NSString *tmpString;
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    // 设置格式本地化,日期格式字符串需要知道是哪个国家的日期，才知道怎么转换
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_us"];
    
    NSInteger interval = [created_at integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    if ([date isThisYear]) { // 今年
        if ([date isToday]) { // 今天
            if ([date isMorning]) {
                fmt.dateFormat = @"凌晨 HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isAM]) {
                fmt.dateFormat = @"上午 HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isPM]) {
                fmt.dateFormat = @"下午 HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isNight]) {
                fmt.dateFormat = @"夜晚 HH:mm";
                tmpString = [fmt stringFromDate:date];
            }
        } else if ([date isYesterday]) { // 昨天
            if ([date isMorning]) {
                fmt.dateFormat = @"昨天 凌晨HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isAM]) {
                fmt.dateFormat = @"昨天 上午HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isPM]) {
                fmt.dateFormat = @"昨天 下午HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isNight]) {
                fmt.dateFormat = @"昨天 夜晚HH:mm";
                tmpString = [fmt stringFromDate:date];
            }
        } else if ([date isInSevenDay]) { // 7天内
            if ([date isMorning]) {
                fmt.dateFormat = [NSString stringWithFormat:@"%@ 凌晨HH:mm", [self weekDayWithDate:date]];
                tmpString = [fmt stringFromDate:date];
            } else if ([date isAM]) {
                fmt.dateFormat = [NSString stringWithFormat:@"%@ 上午HH:mm", [self weekDayWithDate:date]];
                tmpString = [fmt stringFromDate:date];
            } else if ([date isPM]) {
                fmt.dateFormat = [NSString stringWithFormat:@"%@ 下午HH:mm", [self weekDayWithDate:date]];
                tmpString = [fmt stringFromDate:date];
            } else if ([date isNight]) {
                fmt.dateFormat = [NSString stringWithFormat:@"%@ 夜晚HH:mm", [self weekDayWithDate:date]];
                tmpString = [fmt stringFromDate:date];
            }
        } else {
            if ([date isMorning]) {
                fmt.dateFormat = @"MM-dd 凌晨HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isAM]) {
                fmt.dateFormat = @"MM-dd 上午HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isPM]) {
                fmt.dateFormat = @"MM-dd 下午HH:mm";
                tmpString = [fmt stringFromDate:date];
            } else if ([date isNight]) {
                fmt.dateFormat = @"MM-dd 夜晚HH:mm";
                tmpString = [fmt stringFromDate:date];
            }
        }
    } else { // 不是今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        tmpString = [fmt stringFromDate:date];
    }
    _created_at = tmpString;
}

- (NSString *)weekDayWithDate:(NSDate *)date {
    NSString *weekDayString;
    NSCalendar *calender = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday;
    NSDateComponents *comps = [calender components:unit fromDate:date];
    switch (comps.weekday) {
        case 0:
            weekDayString = @"星期日";
            break;
        case 1:
            weekDayString = @"星期一";
            break;
        case 2:
            weekDayString = @"星期二";
            break;
        case 3:
            weekDayString = @"星期三";
            break;
        case 4:
            weekDayString = @"星期四";
            break;
        case 5:
            weekDayString = @"星期五";
            break;
        case 6:
            weekDayString = @"星期六";
            break;
            
        default:
            weekDayString = @"";
            break;
    }
    return weekDayString;
}

@end

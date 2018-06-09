//
//  SJChatMessageModel.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJChatMessageModel.h"
#import "TYTextContainer.h"
#import "SJParser.h"
#import "TYAttributedLabel.h"
#import "SJFaceHandler.h"

#define kLabelMargin 10.f
#define kChatCellItemMargin 10.f
#define kChatCellIconImageViewWH 35.f

#define ContentMaxWidth SJScreenW - kChatCellIconImageViewWH * 2 - kChatCellItemMargin * 4 - kLabelMargin * 2
#define kImageMaxWH 120

@implementation SJChatMessageContentModel

- (void)setCreated_at:(NSString *)created_at {
    _created_at = created_at;
    
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
    _time = tmpString;
}

- (NSString *)weekDayWithDate:(NSDate *)date {
    NSString *weekDayString;
    NSCalendar *calender = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday;
    NSDateComponents *comps = [calender components:unit fromDate:date];
    switch (comps.weekday) {
        case 1:
            weekDayString = @"星期日";
            break;
        case 2:
            weekDayString = @"星期一";
            break;
        case 3:
            weekDayString = @"星期二";
            break;
        case 4:
            weekDayString = @"星期三";
            break;
        case 5:
            weekDayString = @"星期四";
            break;
        case 6:
            weekDayString = @"星期五";
            break;
        case 7:
            weekDayString = @"星期六";
            break;
            
        default:
            weekDayString = @"";
            break;
    }
    return weekDayString;
}

- (void)setContent:(NSString *)content {
    _content = content;
    [self handle];
}

#pragma 处理
-(void)handle {
    [self parseAllKeywords];
    if (self.content) {
        // 计算问题高度
        [self calculateContentHegihtAndAttributedString];
    }
}

#pragma 解析关键词
- (void)parseAllKeywords {
    NSString *content = self.content;
    if (content != nil) {
        self.emotionArray = [SJParser keywordRangesOfEmotionInString:content];
        self.fontArray = [SJParser keywordRangesOfFontColorInString:content];
        self.urlArray = [SJParser keywordRangesOfURLInString:content];
        self.stockArray = [SJParser keywordRangesOfStockColorInString:content];
    }
}

- (void)calculateContentHegihtAndAttributedString {
    NSString *string = [SJParser getHandleString:self.content];
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.characterSpacing = 0;
    textContainer.linesSpacing = 0;
    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    textContainer.font = [UIFont systemFontOfSize:14];
    textContainer.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    textContainer.text = string;
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情和图片
    for (int i = 0; i < self.emotionArray.count; i++) {
        NSString *tmpStr = self.emotionArray[i];
        NSRange range = [string rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
            NSRange rangeOne = [tmpStr rangeOfString:@"common.csjimg.com/emot/qq"];
            if (rangeOne.location != NSNotFound) {
                // 表情
                NSString *indexStr = tmpStr;
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@"http://common.csjimg.com/emot/qq/" withString:@""];
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@".gif" withString:@""];
                
                TYImageStorage *imageStorage = [[TYImageStorage alloc] init];
                imageStorage.range = range;
                imageStorage.size = CGSizeMake(20, 20);
                if ([phoneFaceArray containsObject:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]]) {
                    imageStorage.imageName = [NSString stringWithFormat:@"MLEmoji_Expression.bundle/%@", [phoneFaceDictionary objectForKey:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]]];
                } else {
                    imageStorage.imageURL = [NSURL URLWithString:tmpStr];
                }
                [textContainer addTextStorage:imageStorage];
            } else {
                // 图片
                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView sd_setImageWithURL:[NSURL URLWithString:tmpStr] placeholderImage:[UIImage imageNamed:@"70×70"]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                TYViewStorage *viewStorage = [[TYViewStorage alloc]init];
                viewStorage.range = range;
                viewStorage.view = imageView;
                viewStorage.imgUrl = tmpStr;
                
                if (!_isRefresh) {
                    viewStorage.size = CGSizeMake(70, 70);
                    [textContainer addTextStorage:viewStorage];
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmpStr]];
                        UIImage *img = [UIImage imageWithData:imgData];
                        CGFloat imgWidth = img.size.width;
                        CGFloat imgHeight = img.size.height;
                        
                        CGFloat standardWidthHeightRatio = kImageMaxWH / kImageMaxWH;
                        CGFloat widthHeightRatio = 0;
                        if (imgWidth > kImageMaxWH || imgHeight > kImageMaxWH) {
                            widthHeightRatio = imgWidth / imgHeight;
                            if (widthHeightRatio > standardWidthHeightRatio) {
                                self.imgWidth = kImageMaxWH;
                                self.imgHeight = kImageMaxWH * (imgHeight / imgWidth);
                            } else {
                                self.imgHeight = kImageMaxWH;
                                self.imgWidth = kImageMaxWH * widthHeightRatio;
                            }
                        } else {
                            self.imgWidth = imgWidth;
                            self.imgHeight = imgHeight;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.refreshRowData) {
                                self.refreshRowData(self);
                            }
                        });
                    });
                } else {
                    viewStorage.size = CGSizeMake(self.imgWidth, self.imgHeight);
                    [textContainer addTextStorage:viewStorage];
                }
            }
        }
    }
    
    // url链接
    for (NSDictionary *tmpDic in self.urlArray) {
        NSRange range = [string rangeOfString:tmpDic[@"text"]];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = tmpDic[@"text"];
            linkTextStorage.linkData = tmpDic[@"url"];
            linkTextStorage.underLineStyle=kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }
    
    // 字体颜色
    for (NSString *tmpStr in self.fontArray) {
        NSRange range = [string rangeOfString:tmpStr];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = nil;
            linkTextStorage.linkData = tmpStr;
            linkTextStorage.textColor = [UIColor redColor];
            linkTextStorage.underLineStyle=kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }
    
    // 股票代码
    for (NSString *tmpStr in self.stockArray) {
        NSRange range = [string rangeOfString:tmpStr];
        if (range.location != NSNotFound) {
            TYLinkTextStorage *linkTextStorage=[[TYLinkTextStorage alloc]init];
            linkTextStorage.range = range;
            linkTextStorage.text = nil;
            linkTextStorage.linkData = tmpStr;
            linkTextStorage.textColor = RGB(18, 126, 171);
            linkTextStorage.underLineStyle=kCTUnderlineStyleNone;
            [textContainer addTextStorage:linkTextStorage];
        }
    }

    TYAttributedLabel *label = [[TYAttributedLabel alloc] init];
    [label setTextContainer:textContainer];
    label.frame = CGRectMake(0, 0, CGFLOAT_MAX, 21);
    label.isWidthToFit = YES;
    [label sizeToFit];
    
    if (label.frame.size.width >= ContentMaxWidth) {
        _textWidth = ContentMaxWidth;
        _textContainer = [textContainer createTextContainerWithTextWidth:ContentMaxWidth];
    } else {
        _textWidth = label.frame.size.width;
        _textContainer = [textContainer createTextContainerWithTextWidth:_textWidth];
    }
    
    self.emotionArray = nil;
    self.urlArray = nil;
    self.fontArray = nil;
    self.stockArray = nil;
}

@end

#import "SJToken.h"
#import "MJExtension.h"

@implementation SJChatMessageModel

- (void)setUser_id:(NSString *)user_id {
    _user_id = user_id;
    SJToken *instance = [SJToken sharedToken];
    
    if ([instance.userid isEqualToString:_user_id]) {
        self.messageType = SJMessageTypeSendToOthers;
    } else {
        self.messageType = SJMessageTypeSendToMe;
    }
}

- (void)setData:(NSString *)data {
    _data = data;
    
    NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    self.model = [SJChatMessageContentModel objectWithKeyValues:tmpDic];
}

@end

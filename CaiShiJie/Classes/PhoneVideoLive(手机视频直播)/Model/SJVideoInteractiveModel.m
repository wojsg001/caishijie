//
//  SJVideoInteractiveModel.m
//  CaiShiJie
//
//  Created by user on 18/11/16.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoInteractiveModel.h"
#import "SJParser.h"
#import "SJFaceHandler.h"
#import "RegexKitLite.h"
#import "MJExtension.h"

@implementation SJInteractiveDataModel



@end

@implementation SJVideoInteractiveModel

- (void)setData:(NSString *)data {
    _data = data;
    
    NSData *strData = [_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    _model = [SJInteractiveDataModel objectWithKeyValues:dict];
    // 处理字符串
    [self handle];
}

#pragma 处理
-(void)handle {
    if ([_type isEqualToString:@"40"]) {
        // 互动
        _text = [NSString stringWithFormat:@"%@：%@", _model.nickname, _model.content];
    } else if ([_type isEqualToString:@"1"]) {
        // 礼物
        _text = [NSString stringWithFormat:@"%@：赠送给主播%@x%@<img src=\"http://common.csjimg.com/gift/%@\">", _model.nickname, _model.item_name, _model.item_count, _model.item_img];
    }
    if (!self.text) {
        return;
    }
    [self parseAllKeywords];
    [self creatAttributedString];
}

#pragma 解析关键词
- (void)parseAllKeywords {
    self.emotionArray = [SJParser keywordRangesOfEmotionInString:_text];
    self.stockArray = [SJParser keywordRangesOfStockColorInString:_text];
}

- (void)creatAttributedString {
    NSString *string = [SJParser getHandleString:self.text];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attString.length)];
    
    NSArray *computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    NSArray *phoneFaceArray = [[SJFaceHandler sharedFaceHandler] getPhoneFaceArray];
    NSDictionary *phoneFaceDictionary = [[SJFaceHandler sharedFaceHandler] getPhoneFaceDictionary];
    // 表情和图片
    for (int i = 0; i < self.emotionArray.count; i++) {
        NSString *tmpStr = self.emotionArray[i];
        NSRange range = [[attString string] rangeOfString:[NSString stringWithFormat:@"[img%i]",i]];
        if (range.location != NSNotFound) {
            NSRange rangeOne = [tmpStr rangeOfString:@"common.csjimg.com/emot/qq"];
            if (rangeOne.location != NSNotFound) {
                // 表情
                NSString *indexStr = tmpStr;
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@"http://common.csjimg.com/emot/qq/" withString:@""];
                indexStr = [indexStr stringByReplacingOccurrencesOfString:@".gif" withString:@""];
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.bounds = CGRectMake(0, -4, 18, 18);
                if ([phoneFaceArray containsObject:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]]) {
                    textAttachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"MLEmoji_Expression.bundle/%@", [phoneFaceDictionary objectForKey:[computerFaceArray objectAtIndex:[indexStr integerValue] - 1]]]];
                } else {
                    textAttachment.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tmpStr]]];
                }
                [attString replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            } else {
                // 礼物
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.bounds = CGRectMake(0, -5, 20, 20);
                textAttachment.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tmpStr]]];
                [attString replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            }
        }
    }
    
    // 股票代码
    for (NSString *tmpStr in self.stockArray) {
        NSRange range = [[attString string] rangeOfString:tmpStr];
        if (range.location != NSNotFound) {
            [attString addAttribute:NSForegroundColorAttributeName value:RGB(18, 126, 171) range:range];
        }
    }
    
    NSRange range = [[attString string] rangeOfString:_model.nickname];
    if (range.location != NSNotFound) {
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f76408" withAlpha:1] range:range];
    }
    NSRange tmpRange = [[attString string] rangeOfString:[NSString stringWithFormat:@"%@x%@", _model.item_name, _model.item_count]];
    if (tmpRange.location != NSNotFound) {
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f36575" withAlpha:1] range:tmpRange];
    }
    
    _attributedString = attString;
    
    self.emotionArray = nil;
    self.stockArray = nil;
}

@end

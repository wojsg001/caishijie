//
//  SJYiJingHuiDaModel.m
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJYiJingHuiDaModel.h"

#import "SJYiJingHuiDaQuestion.h"
#import "MJExtension.h"

@implementation SJYiJingHuiDaModel

- (void)setData:(NSString *)data
{
    _data = data;
    
    NSString *str = _data;
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    
    _YiJingHuiDaQuestionModel = [SJYiJingHuiDaQuestion objectWithKeyValues:dict];
}

- (void)setAnswer_count:(NSString *)answer_count
{
    _answer_count = [NSString stringWithFormat:@"%@人回答",answer_count];
}

@end

//
//  SJUserQuestionModel.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserQuestionModel.h"

#import "SJUserQuestionDetail.h"
#import "MJExtension.h"

@implementation SJUserQuestionModel

- (void)setAnswer_count:(NSString *)answer_count
{
    _answer_count = [NSString stringWithFormat:@"%@人回答",answer_count];
}

- (void)setData:(NSString *)data
{
    _data = data;
    
    NSString *str = _data;
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    
    _questionDetail = [SJUserQuestionDetail objectWithKeyValues:dict];
}

@end

//
//  SJUserAnswerModel.m
//  CaiShiJie
//
//  Created by user on 16/1/15.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJUserAnswerModel.h"

#import "SJUserAnswerDetail.h"
#import "MJExtension.h"

@implementation SJUserAnswerModel

- (void)setData:(NSString *)data
{
    _data = data;
    
    NSString *str = _data;
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    
    _answerDetail = [SJUserAnswerDetail objectWithKeyValues:dict];
}

@end

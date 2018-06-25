//
//  SJWeiHuiDaModel.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJWeiHuiDaModel.h"

#import "SJWeiHuiDaQuestion.h"
#import "MJExtension.h"

@implementation SJWeiHuiDaModel

- (void)setData:(NSString *)data
{
    _data = data;
    
    NSString *str = _data;
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    
    _WeiHuiDaQuestionModel = [SJWeiHuiDaQuestion objectWithKeyValues:dict];
}

@end

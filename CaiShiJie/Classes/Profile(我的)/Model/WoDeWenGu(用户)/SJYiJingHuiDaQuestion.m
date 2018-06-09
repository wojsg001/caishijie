//
//  SJYiJingHuiDaQuestion.m
//  CaiShiJie
//
//  Created by user on 16/1/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJYiJingHuiDaQuestion.h"
#import "SJYiJingHuiDaAnswer.h"
#import "MJExtension.h"

@implementation SJYiJingHuiDaQuestion

- (void)setAnswer:(NSDictionary *)answer
{
    _answer = answer;
    
    _YiJingHuiDaAnswerModel = [SJYiJingHuiDaAnswer objectWithKeyValues:answer];
}

- (void)setContent:(NSString *)content
{
    NSString *str = content;
    str = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    _content = [NSString stringWithFormat:@"【问】：%@",str];
}

@end

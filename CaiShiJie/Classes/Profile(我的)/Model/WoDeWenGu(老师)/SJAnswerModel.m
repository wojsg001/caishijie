//
//  SJAnswerModel.m
//  CaiShiJie
//
//  Created by user on 16/1/13.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJAnswerModel.h"

@implementation SJAnswerModel

- (void)setData:(NSString *)data {
    _data = data;
    
    NSData *tmpData =[_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tmpDic =[NSJSONSerialization JSONObjectWithData:tmpData options:NSJSONReadingMutableLeaves error:nil];
    NSDictionary *answerDic = tmpDic[@"answer"];
    self.answer = [NSString stringWithFormat:@"【回答】:%@",answerDic[@"content"]];
    self.content = [NSString stringWithFormat:@"【问】:%@",tmpDic[@"content"]];
    _head_img = tmpDic[@"head_img"];
    _nickname = tmpDic[@"nickname"];
    _answer_count = [NSString stringWithFormat:@"%@人回答", answerDic[@"answer_count"]];
    _created_at = [NSString stringWithFormat:@"%@",tmpDic[@"created_at"]];
    _item_id = tmpDic[@"item_id"];
}

- (void)setContent:(NSString *)content
{
    NSString *str = content;
    str = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    _content = str;
}

- (void)setAnswer:(NSString *)answer
{
    NSString *str = answer;
    str = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    _answer = str;
}

@end

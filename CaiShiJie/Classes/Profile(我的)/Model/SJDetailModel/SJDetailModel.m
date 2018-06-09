//
//  SJDetailModel.m
//  CaiShiJie
//
//  Created by user on 16/1/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJDetailModel.h"

@implementation SJDetailModel

- (instancetype)initwithdic:(NSDictionary *)dic {//这个字典代表question
    if ([super init]) {
        self.answer_count = [NSString stringWithFormat:@"%@人回答",dic[@"answer_count"]];
        
        NSString *dataStr = dic[@"data"];
        NSData *data1 = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableLeaves error:nil];
        self.content = dict[@"content"];
        self.created_at = [NSString stringWithFormat:@"%@", dict[@"created_at"]];
        self.head_img = dict[@"head_img"];
        self.nickname = dict[@"nickname"];
    }
    return self;
}

+ (instancetype)detailwith:(NSDictionary *)dict {
    return [[self alloc] initwithdic:dict];
}

- (void)setContent:(NSString *)content {
    NSString *str = content;
    str = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    _content = [NSString stringWithFormat:@"【问】：%@", str];
}

@end

//
//  SJRecommendVideoModel.m
//  CaiShiJie
//
//  Created by user on 16/5/13.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJRecommendVideoModel.h"

@implementation SJRecommendVideoModel

- (void)setData:(NSString *)data
{
    _data = data;

    NSData *strData = [_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    _nickname = dic[@"nickname"];
    _title = dic[@"title"];
    _summary = dic[@"summary"];
}

- (void)setVod:(NSString *)vod
{
    _vod = vod;
    
    NSData *strData = [_vod dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    _img = dic[@"img"];
    _url = dic[@"url"];
}

@end

//
//  SJVideoInfoListModel.m
//  CaiShiJie
//
//  Created by user on 16/7/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJVideoInfoListModel.h"

@implementation SJVideoInfoListModel

- (void)setVod:(NSString *)vod {
    _vod = vod;

    NSData *data = [_vod dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    _url = tmpDic[@"url"];
}

@end

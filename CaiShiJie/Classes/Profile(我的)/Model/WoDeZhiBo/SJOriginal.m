//
//  SJOriginal.m
//  CaiShiJie
//
//  Created by user on 16/1/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJOriginal.h"
#import "RegexKitLite.h"

@implementation SJOriginal

- (void)setContent:(NSString *)content
{
    NSString *str = [NSString stringWithFormat:@"%@:%@",_nickname,content];
    str = [str stringByReplacingOccurrencesOfRegex:@"(<br\\s+/>|<br/>|<br>)" withString:@"\n"];
    str = [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    _content = str;
}

@end

//
//  SJBlogRankModel.m
//  CaiShiJie
//
//  Created by user on 16/5/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogRankModel.h"

@implementation SJBlogRankModel

- (void)setClicks:(NSString *)clicks {
    NSInteger clickCount = [clicks integerValue];
    NSString *tmpStr;
    if (clickCount < 10000) {
        tmpStr = clicks;
    } else {
        CGFloat tmpClickCount = clickCount / 10000.0;
        tmpStr = [NSString stringWithFormat:@"%.1f万", tmpClickCount];
    }
    _clicks = tmpStr;
}

@end

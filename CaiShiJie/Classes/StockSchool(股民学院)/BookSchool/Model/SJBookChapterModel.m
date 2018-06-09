//
//  SJBookChapterModel.m
//  CaiShiJie
//
//  Created by user on 16/4/20.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBookChapterModel.h"

@implementation SJBookChapterModel

- (void)setTitle:(NSString *)title
{
    NSString *str = title;
    str = [str stringByReplacingOccurrencesOfString:@"&amp;#8226;" withString:@"."];
    str = [str stringByReplacingOccurrencesOfString:@"&#183;" withString:@"."];
    
    _title = str;
}

@end

//
//  SJBookSectionModel.m
//  CaiShiJie
//
//  Created by user on 18/4/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBookSectionModel.h"

@implementation SJBookSectionModel

- (void)setTitle:(NSString *)title
{
    NSString *str = title;
    str = [str stringByReplacingOccurrencesOfString:@"&amp;#8226;" withString:@"."];
    str = [str stringByReplacingOccurrencesOfString:@"&#183;" withString:@"."];
    
    _title = str;
}

@end

//
//  SJBookListModel.m
//  CaiShiJie
//
//  Created by user on 16/4/20.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBookListModel.h"

@implementation SJBookListModel

- (void)setAuthor:(NSString *)author
{
    NSString *str = author;
    str = [str stringByReplacingOccurrencesOfString:@"&amp;#8226;" withString:@"."];
    str = [str stringByReplacingOccurrencesOfString:@"&#183;" withString:@"."];
    
    _author = str;
}

- (void)setTitle:(NSString *)title
{
    NSString *str = title;
    str = [str stringByReplacingOccurrencesOfString:@"&amp;#8226;" withString:@"."];
    str = [str stringByReplacingOccurrencesOfString:@"&#183;" withString:@"."];
    
    _title = str;
}

@end

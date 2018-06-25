//
//  SJCustom.m
//  CaiShiJie
//
//  Created by user on 18/1/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCustom.h"

@implementation SJCustom

+ (instancetype)customWithDict:(NSDictionary *)dict {
    id custom = [[self alloc] init];
    [custom setValuesForKeysWithDictionary:dict];
    return custom;
}

@end

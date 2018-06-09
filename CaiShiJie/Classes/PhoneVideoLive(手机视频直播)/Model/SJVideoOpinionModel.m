//
//  SJVideoOpinionModel.m
//  CaiShiJie
//
//  Created by user on 16/7/27.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJVideoOpinionModel.h"
#import "MJExtension.h"

@implementation SJOpinionModel

@end

@implementation SJVideoOpinionModel

- (void)setData:(NSString *)data {
    _data = data;
    
    NSData *strData = [_data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    
    _model = [SJOpinionModel objectWithKeyValues:dict];
}

@end

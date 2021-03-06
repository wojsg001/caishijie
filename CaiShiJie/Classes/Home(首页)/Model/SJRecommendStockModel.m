//
//  SJRecommendStockModel.m
//  CaiShiJie
//
//  Created by user on 18/5/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRecommendStockModel.h"

@implementation SJRecommendStockModel

- (void)setZhangdie:(NSString *)zhangdie{
    if ([zhangdie isEqualToString:@"-100"]) {
        _zhangdie = @"----";
    }else {
        double num = [zhangdie doubleValue];
        if (num > 0) {
            _zhangdie = [NSString stringWithFormat:@"+%.2f%@",num,@"%"];
        }else {
            _zhangdie = [NSString stringWithFormat:@"%.2f%@",num,@"%"];
        }
    }
}

- (void)setCurrentPrice:(NSString *)currentPrice {
    _currentPrice = [NSString stringWithFormat:@"%.2f",[currentPrice floatValue]];
}

@end

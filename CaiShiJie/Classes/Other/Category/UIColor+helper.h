//
//  UIColor+helper.h
//  Kline
//
//  Created by zhaomingxi on 14-2-9.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColorModel;
@interface UIColor (helper)

+ (UIColor *)colorWithHexString: (NSString *)color withAlpha:(CGFloat)alpha;
+ (ColorModel *)RGBWithHexString: (NSString *)color withAlpha:(CGFloat)alpha;

@end

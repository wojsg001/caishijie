//
//  UIImage+SJimage_UIcolor.m
//  CaiShiJie
//
//  Created by user on 18/5/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "UIImage+SJimage_UIcolor.h"

@implementation UIImage (SJimage_UIcolor)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}
@end

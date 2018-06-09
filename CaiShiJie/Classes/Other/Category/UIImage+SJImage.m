//
//  UIImage+SJImage.m
//  CaiShiJie
//
//  Created by user on 16/3/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import "UIImage+SJImage.h"

@implementation UIImage (SJImage)

+ (instancetype)imageWithOriginalName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (instancetype)resizableWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    
}

+ (UIImage *)resizableImageWithName:(NSString *)imageName {
    // 加载原有图片
    UIImage *norImage = [UIImage imageNamed:imageName];
    // 获取原有图片的宽高的一半
    CGFloat left = norImage.size.width * 0.45;
    CGFloat right = norImage.size.width * 0.5;
    CGFloat top = norImage.size.height * 0.75;
    CGFloat bottom = norImage.size.height * 0.8;
    // 生成可以拉伸指定位置的图片
    UIImage *newImage = [norImage resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    
    return newImage;
}

@end

//
//  UIImage+SJImage.h
//  CaiShiJie
//
//  Created by user on 16/3/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SJImage)

// 加载最原始的图片，没有渲染
+ (instancetype)imageWithOriginalName:(NSString *)imageName;

+ (instancetype)resizableWithImageName:(NSString *)imageName;

// 图片拉伸
+ (UIImage *)resizableImageWithName:(NSString *)imageName;

@end

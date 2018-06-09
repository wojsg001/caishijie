//
//  SJTimeLines.m
//  QuartzDemo
//
//  Created by user on 16/9/23.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTimeLines.h"
#import "UIColor+helper.h"

@implementation SJTimeLines

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSetting];
    }
    return self;
}

- (void)initSetting {
    self.backgroundColor = [UIColor clearColor];
    self.startPoint = self.frame.origin;
    self.endPoint = self.frame.origin;
    self.hexColor = @"#000000";
    self.lineWidth = 1.0f;
    self.isVol = NO;
    self.isDashes = NO;
    self.isTimeLine = NO;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.isVol) {
        // 画成交量
        for (NSArray *item in self.points) {
            // 转换坐标
            CGPoint heightPoint,lowPoint;
            heightPoint = CGPointFromString([item objectAtIndex:0]);
            lowPoint = CGPointFromString([item objectAtIndex:1]);
            if ([self.points indexOfObject:item] > 0) {
                NSArray *lastItem = [self.points objectAtIndex:[self.points indexOfObject:item] - 1];
                [self drawKWithContext:context height:heightPoint Low:lowPoint currentPrice:[item objectAtIndex:2] lastPrice:[lastItem objectAtIndex:2] width:self.lineWidth];
            } else {
                [self drawKWithContext:context height:heightPoint Low:lowPoint currentPrice:[item objectAtIndex:2] lastPrice:[item objectAtIndex:3] width:self.lineWidth];
            }
        }
    } else {
        // 画连接线
        [self drawLineWithContext:context];
    }
}
#pragma mark 画连接线
- (void)drawLineWithContext:(CGContextRef)context {
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:self.hexColor withAlpha:self.alpha].CGColor);
    if (self.startPoint.x == self.endPoint.x && self.endPoint.y == self.startPoint.y) {
        // 画多点连线
        CGMutablePathRef fillPath = CGPathCreateMutable(); // 填充路径
        CGPathMoveToPoint(fillPath, nil, 0, self.frame.size.height);
        for (id item in self.points) {
            CGPoint currentPoint = CGPointFromString(item);
            if (currentPoint.y <= self.frame.size.height && currentPoint.y >= 0) {
                CGPathAddLineToPoint(fillPath, nil, currentPoint.x, currentPoint.y);
                if ([self.points indexOfObject:item] == 0) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    continue;
                }
                CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                if ([self.points indexOfObject:item] == self.points.count - 1) {
                    CGPathAddLineToPoint(fillPath, nil, currentPoint.x, self.frame.size.height);
                    CGPathCloseSubpath(fillPath);
                }
            }
        }
        CGContextStrokePath(context);
        if (self.isTimeLine) {
            [self drawLinearGradientWithContext:context path:fillPath startColor:[UIColor colorWithHexString:@"#3299CC" withAlpha:1] endColor:[UIColor colorWithHexString:@"#3299CC" withAlpha:1]];
        }
    } else if (self.isDashes) {
        // 画两点虚线
        CGFloat lengths[] = {5, 2};
        CGContextSetLineDash(context, 0, lengths, 2);
        const CGPoint points[] = {self.startPoint, self.endPoint};
        CGContextStrokeLineSegments(context, points, 2);
    } else {
        // 画两点连线
        const CGPoint points[] = {self.startPoint, self.endPoint};
        CGContextStrokeLineSegments(context, points, 2); // 绘制线段（默认不绘制端点）
    }
}

- (void)drawLinearGradientWithContext:(CGContextRef)context path:(CGMutablePathRef)fillPath startColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    const CGFloat locations[] = {0.0, 1.0};
    NSArray *colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(fillPath);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGContextSaveGState(context);
    CGContextAddPath(context, fillPath);
    CGContextClip(context);
    CGContextSetAlpha(context, 0.3);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

#pragma mark 画成交量
- (void)drawKWithContext:(CGContextRef)context height:(CGPoint)heightPoint Low:(CGPoint)lowPoint currentPrice:(NSString *)price lastPrice:(NSString *)lastPrice width:(CGFloat)width {
    UIColor *color = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha]; // 设置默认红色
    // 如果当期分钟的价格大于上一分钟的价格则为红
    if ([price floatValue] > [lastPrice floatValue]) {
        color = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha];
    } else if ([price floatValue] < [lastPrice floatValue]) {
        color = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
    }
    // 设置颜色
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, width);
    const CGPoint point[] = {heightPoint, lowPoint};
    CGContextStrokeLineSegments(context, point, 2); // 绘制线段
}

@end

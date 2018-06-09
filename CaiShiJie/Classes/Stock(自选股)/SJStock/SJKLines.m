//
//  SJKLines.m
//  QuartzDemo
//
//  Created by user on 16/9/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJKLines.h"
#import "UIColor+helper.h"

@implementation SJKLines

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
    self.isK = NO;
    self.isVol = NO;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.isK) {
        // 画K线
        for (NSArray *item in self.points ) {
            // 转换坐标
            CGPoint heightPoint, lowPoint, openPoint, closePoint;
            heightPoint = CGPointFromString([item objectAtIndex:0]);
            lowPoint = CGPointFromString([item objectAtIndex:1]);
            openPoint = CGPointFromString([item objectAtIndex:2]);
            closePoint = CGPointFromString([item objectAtIndex:3]);
            [self drawKWithContext:context height:heightPoint Low:lowPoint open:openPoint close:closePoint width:self.lineWidth];
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
        for (id item in self.points) {
            CGPoint currentPoint = CGPointFromString(item);
            if (currentPoint.y < self.frame.size.height && currentPoint.y > 0) {
                if ([self.points indexOfObject:item] == 0) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    continue;
                }
                CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                CGContextStrokePath(context); // 开始画线
                if ([self.points indexOfObject:item] < self.points.count) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                }
            }
        }
    } else {
        // 画两点连线
        const CGPoint points[] = {self.startPoint, self.endPoint};
        CGContextStrokeLineSegments(context, points, 2); // 绘制线段（默认不绘制端点）
    }
}

#pragma mark 画一根K线
-(void)drawKWithContext:(CGContextRef)context height:(CGPoint)heightPoint Low:(CGPoint)lowPoint open:(CGPoint)openPoint close:(CGPoint)closePoint width:(CGFloat)width {
    // 首先判断是红还是绿，根据开盘价和收盘价的坐标来计算
    BOOL isKong = NO;
    UIColor *color = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha]; // 设置默认红色
    // 如果开盘价坐标在收盘价坐标的上方，则为绿色，即空
    if (openPoint.y < closePoint.y) {
        isKong = YES;
        color = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
    }
    // 设置颜色
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    // 首先画一个垂直的线包含上影线和下影线
    // 定义两个点，画两点连线
    if (!self.isVol) {
        CGContextSetLineWidth(context, 1); // 上下阴影线的宽度
        if (self.lineWidth <= 2) {
            CGContextSetLineWidth(context, 0.5); // 上下阴影线的宽度
        }
        const CGPoint points[] = {heightPoint,lowPoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
    // 再画中间的实体
    CGContextSetLineWidth(context, width); // 改变线的宽度
    CGFloat halfWidth = 0; // width/2;
    // 纠正实体的中心点为当前坐标
    openPoint = CGPointMake(openPoint.x - halfWidth, openPoint.y);
    closePoint = CGPointMake(closePoint.x - halfWidth, closePoint.y);
    
    if (self.isVol) {
        openPoint = CGPointMake(heightPoint.x - halfWidth, heightPoint.y);
        closePoint = CGPointMake(lowPoint.x - halfWidth, lowPoint.y);
    }
    // 开始画实体
    const CGPoint point[] = {openPoint, closePoint};
    CGContextStrokeLineSegments(context, point, 2);  // 绘制线段（默认不绘制端点）
    //CGContextSetLineCap(context, kCGLineCapSquare) ;// 设置线段的端点形状，方形
}

@end

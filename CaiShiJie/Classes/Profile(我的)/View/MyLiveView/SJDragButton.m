//
//  SJDragButton.m
//  CaiShiJie
//
//  Created by user on 16/3/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJDragButton.h"

@interface SJDragButton ()
{
    CGPoint beginPoint;
}

@end

@implementation SJDragButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setImage:[UIImage imageNamed:@"zhibo_icon_n"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.dragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    beginPoint = [touch locationInView:self];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.dragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
    
    self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
    
    // x轴左右极限坐标
    if (self.center.x > SJScreenW - self.frame.size.width/2)
    {
        CGFloat x = SJScreenW - self.frame.size.width/2;
        self.center = CGPointMake(x, self.center.y + offsetY);
    }
    else if (self.center.x < self.frame.size.width/2)
    {
        CGFloat x = self.frame.size.width/2;
        self.center = CGPointMake(x, self.center.y + offsetY);
    }
    
    // y轴上下极限坐标
    if (self.center.y > SJScreenH - self.frame.size.height/2)
    {
        CGFloat x = self.center.x;
        CGFloat y = SJScreenH - self.frame.size.height/2;
        self.center = CGPointMake(x, y);
    }
    else if (self.center.y <= self.frame.size.height/2)
    {
        CGFloat x = self.center.x;
        CGFloat y = self.frame.size.height/2;
        self.center = CGPointMake(x, y);
    }
}

@end

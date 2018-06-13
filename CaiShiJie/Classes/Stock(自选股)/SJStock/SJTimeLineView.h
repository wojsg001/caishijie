//
//  SJTimeLineView.h
//  QuartzDemo
//
//  Created by user on 16/9/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^updateBlock)(id);

@interface SJTimeLineView : UIView

/**
 *  存放需要展示的数据
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  价格最大值
 */
@property (nonatomic, assign) CGFloat priceMaxValue;
@property (nonatomic, assign) CGFloat preClose;
/**
 *  价格最小值
 */
@property (nonatomic, assign) CGFloat priceMinValue;
/**
 *  幅度最大值
 */
@property (nonatomic, assign) CGFloat netChangeRatioMaxValue;
/**
 *  幅度最小值
 */
@property (nonatomic, assign) CGFloat netChangeRatioMinValue;
/**
 *  成交量最大值
 */
@property (nonatomic, assign) CGFloat volMaxValue;
/**
 *  X轴宽度
 */
@property (nonatomic, assign) CGFloat xWidth;
/**
 *  Y轴高度
 */
@property (nonatomic, assign) CGFloat yHeight;
/**
 *  底部盒子Y轴高度
 */
@property (nonatomic, assign) CGFloat bottomBoxHeight;
/**
 *  分时点宽度
 */
@property (nonatomic, assign) CGFloat timePointWidth;
/**
 *  字体大小
 */
@property (nonatomic, retain) UIFont *font;
/**
 *  定义一个block回调,更新界面
 */
@property (nonatomic, copy  ) updateBlock finishUpdateBlock;

- (void)start;
- (void)update;

@end

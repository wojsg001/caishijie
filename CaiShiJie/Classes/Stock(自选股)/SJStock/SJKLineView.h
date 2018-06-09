//
//  SJKLineView.h
//  QuartzDemo
//
//  Created by user on 16/9/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^updateBlock)(id);

@interface SJKLineView : UIView
/**
 *  存放源数据
 */
@property (nonatomic, strong) NSMutableArray *originalDataArray;
/**
 *  存放需要展示的数据
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  收盘价最大值
 */
@property (nonatomic, assign) CGFloat maxValue;
/**
 *  收盘价最小值
 */
@property (nonatomic, assign) CGFloat minValue;
/**
 *  成交量最大值
 */
@property (nonatomic, assign) CGFloat volMaxValue;
/**
 *  x轴宽度
 */
@property (nonatomic, assign) CGFloat xWidth;
/**
 *  y轴高度
 */
@property (nonatomic, assign) CGFloat yHeight;
/**
 *  底部y轴高度
 */
@property (nonatomic, assign) CGFloat bottomBoxHeight;
/**
 *  K线的宽度,用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
 */
@property (nonatomic, assign) CGFloat kLineWidth;
/**
 *  K线间隔
 */
@property (nonatomic, assign) CGFloat kLinePadding;
/**
 *  k线中实体的总数,通过 xWidth/kLineWidth计算而来
 */
@property (nonatomic, assign) NSInteger kCount;
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

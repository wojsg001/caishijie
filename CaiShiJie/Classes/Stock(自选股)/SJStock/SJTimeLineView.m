//
//  SJTimeLineView.m
//  QuartzDemo
//
//  Created by user on 16/9/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTimeLineView.h"
#import "SJTimeLines.h"
#import "UIColor+helper.h"
#import "Masonry.h"
#import "SJTimePopUpView.h"
#import <BlocksKit/NSArray+BlocksKit.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define KMoveLinePointWidth 4
#define Padding 2

@interface SJTimeLineView ()

@property (nonatomic, strong) UIView *aboveBoxView; // 分时图控件
@property (nonatomic, strong) UIView *bottomBoxView; // 成交量控件
@property (nonatomic, strong) NSMutableArray *pointArray; //分时所有坐标数组
@property (nonatomic, strong) UILabel *volMaxValueLabel; // 显示成交量最大值
@property (nonatomic, strong) NSMutableArray *timeLineArray; // 分时线数组
@property (nonatomic, strong) NSMutableArray *timeLineOldArray; // 分时线旧数组
@property (nonatomic, strong) UIView *moveLineOne; // 手指按下后显示的两根十字线
@property (nonatomic, strong) UIView *moveLineTwo;
@property (nonatomic, strong) UIView *moveLinePoint;
@property (nonatomic, strong) SJTimePopUpView *movePopUpView;
@property (nonatomic, assign) CGPoint touchViewPoint;
@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, assign) BOOL isUpdateFinish;

@end

@implementation SJTimeLineView

- (SJTimePopUpView *)movePopUpView {
    if (!_movePopUpView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJStockUI" owner:nil options:nil];
        _movePopUpView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJTimePopUpView class]];
        }];
        _movePopUpView.layer.cornerRadius = 4;
        _movePopUpView.layer.shadowColor = [UIColor blackColor].CGColor;
        _movePopUpView.layer.shadowRadius = 3;
        _movePopUpView.layer.shadowOpacity = 0.2;
        _movePopUpView.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return _movePopUpView;
}

- (NSMutableArray *)timeLineArray {
    if (!_timeLineArray) {
        _timeLineArray = [NSMutableArray array];
    }
    return _timeLineArray;
}

- (NSMutableArray *)timeLineOldArray {
    if (!_timeLineOldArray) {
        _timeLineOldArray = [NSMutableArray array];
    }
    return _timeLineOldArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSetting];
    }
    return self;
}

- (void)initSetting {
    self.xWidth = self.frame.size.width;
    self.yHeight = 150;
    self.bottomBoxHeight = 60;
    self.timePointWidth = self.xWidth/240;
    self.font = [UIFont systemFontOfSize:9];
    self.preClose = 0;
    _isUpdate = NO;
    _isUpdateFinish = YES;
    
    self.finishUpdateBlock = ^(id self) {
        [self updateNib];
    };
}

#pragma mark 更新界面等信息
- (void)updateNib {
    NSLog(@"block");
    if (_moveLineOne == nil) {
        _moveLineOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, _bottomBoxView.frame.size.height + _bottomBoxView.frame.origin.y)];
        _moveLineOne.backgroundColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
        [self addSubview:_moveLineOne];
        _moveLineOne.hidden = YES;
    }
    if (_moveLineTwo == nil) {
        _moveLineTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.xWidth, 0.5)];
        _moveLineTwo.backgroundColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
        _moveLineTwo.hidden = YES;
        [self addSubview:_moveLineTwo];
    }
    if (_moveLinePoint == nil) {
        _moveLinePoint = [[UIView alloc] initWithFrame:CGRectMake(-KMoveLinePointWidth/2, -KMoveLinePointWidth/2, KMoveLinePointWidth, KMoveLinePointWidth)];
        _moveLinePoint.layer.cornerRadius = KMoveLinePointWidth/2;
        _moveLinePoint.layer.masksToBounds = YES;
        _moveLinePoint.backgroundColor = [UIColor blackColor];
        _moveLinePoint.hidden = YES;
        [self addSubview:_moveLinePoint];
    }
    
    _moveLineOne.frame = CGRectMake(_touchViewPoint.x, 0, 0.5, _bottomBoxView.frame.size.height + _bottomBoxView.frame.origin.y);
    _moveLineTwo.frame = CGRectMake(0, _touchViewPoint.y, self.xWidth, 0.5);
    _moveLinePoint.frame = CGRectMake(_touchViewPoint.x - KMoveLinePointWidth/2, _touchViewPoint.y - KMoveLinePointWidth/2, KMoveLinePointWidth, KMoveLinePointWidth);
    _moveLineOne.hidden = NO;
    _moveLineTwo.hidden = NO;
    _moveLinePoint.hidden = NO;
    self.movePopUpView.frame = CGRectMake(0, 20, 70, 85);
    self.movePopUpView.hidden = NO;
    [self addSubview:self.movePopUpView];
    
    [self isTimePointWithPoint:_touchViewPoint];
}

- (void)start {
    [self drawBox];
    [self drawLine];
}

- (void)update {
    _isUpdate = YES;
    self.clearsContextBeforeDrawing = YES;
    [self drawLine];
}

#pragma mark 画框框和平均线
- (void)drawBox {
    WS(weakSelf);
    if (_aboveBoxView == nil) {
        _aboveBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.xWidth, self.yHeight)];
        _aboveBoxView.backgroundColor = [UIColor whiteColor];
        _aboveBoxView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha].CGColor;
        _aboveBoxView.layer.borderWidth = 0.5f;
        _aboveBoxView.userInteractionEnabled = YES;
        [self addSubview:_aboveBoxView];
        // 添加长按手势
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        [longPressGestureRecognizer setMinimumPressDuration:0.3f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
    if (_bottomBoxView == nil) {
        _bottomBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, _aboveBoxView.frame.size.height + 20, self.xWidth, self.bottomBoxHeight)];
        _bottomBoxView.backgroundColor = [UIColor whiteColor];
        _bottomBoxView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha].CGColor;
        _bottomBoxView.layer.borderWidth = 0.5f;
        _bottomBoxView.userInteractionEnabled = YES;
        [self addSubview:_bottomBoxView];
    }
    if (_volMaxValueLabel == nil) {
        _volMaxValueLabel = [[UILabel alloc] init];
        _volMaxValueLabel.font = self.font;
        _volMaxValueLabel.text = @"--";
        _volMaxValueLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
        _volMaxValueLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_volMaxValueLabel];
        [_volMaxValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.bottomBoxView.mas_left).offset(Padding);
            make.top.equalTo(weakSelf.bottomBoxView.mas_top).offset(0);
        }];
    }
    
    if (_isUpdate) {
        return;
    }
    // 横向分割线
    CGFloat padYRealValue = self.yHeight / 4;
    for (int i = 1; i < 4; i++) {
        CGFloat y = padYRealValue * i;
        if (i == 2) {
            SJTimeLines *line = [[SJTimeLines alloc] initWithFrame:CGRectMake(0, 0, self.xWidth, self.yHeight)];
            line.hexColor = @"#e3e3e3";
            line.startPoint = CGPointMake(0, y);
            line.endPoint = CGPointMake(self.xWidth, y);
            line.isDashes = YES;
            [_aboveBoxView addSubview:line];
        } else {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.xWidth, 0.5)];
            line.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha];
            [_aboveBoxView addSubview:line];
        }
    }
    
    // 竖向分割线
    CGFloat padXRealValue = self.xWidth / 4;
    for (int i = 1; i < 4; i++) {
        CGFloat x = padXRealValue * i;
        UIView *aboveLine = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 0.5, self.yHeight)];
        aboveLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha];
        [_aboveBoxView addSubview:aboveLine];
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 0.5, self.bottomBoxHeight)];
        bottomLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha];
        [_bottomBoxView addSubview:bottomLine];
    }
    
    // 时间显示控件
    CGFloat timeY = self.yHeight + 5;
    UILabel *timeLabelOne = [[UILabel alloc] init];
    timeLabelOne.backgroundColor = [UIColor clearColor];
    timeLabelOne.text = @"9:30";
    timeLabelOne.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
    timeLabelOne.font = self.font;
    [timeLabelOne sizeToFit];
    timeLabelOne.frame = CGRectMake(0, timeY, timeLabelOne.frame.size.width, timeLabelOne.frame.size.height);
    [self addSubview:timeLabelOne];
    
    UILabel *timeLabelTwo = [[UILabel alloc] init];
    timeLabelTwo.backgroundColor = [UIColor clearColor];
    timeLabelTwo.text = @"10:30";
    timeLabelTwo.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
    timeLabelTwo.font = self.font;
    [timeLabelTwo sizeToFit];
    timeLabelTwo.frame = CGRectMake(padXRealValue - timeLabelTwo.frame.size.width / 2, timeY, timeLabelTwo.frame.size.width, timeLabelTwo.frame.size.height);
    [self addSubview:timeLabelTwo];
    
    UILabel *timeLabelThree = [[UILabel alloc] init];
    timeLabelThree.backgroundColor = [UIColor clearColor];
    timeLabelThree.text = @"11:30/13:00";
    timeLabelThree.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
    timeLabelThree.font = self.font;
    [timeLabelThree sizeToFit];
    timeLabelThree.frame = CGRectMake(padXRealValue * 2 - timeLabelThree.frame.size.width / 2, timeY, timeLabelThree.frame.size.width, timeLabelThree.frame.size.height);
    [self addSubview:timeLabelThree];
    
    UILabel *timeLabelFour = [[UILabel alloc] init];
    timeLabelFour.backgroundColor = [UIColor clearColor];
    timeLabelFour.text = @"14:30";
    timeLabelFour.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
    timeLabelFour.font = self.font;
    [timeLabelFour sizeToFit];
    timeLabelFour.frame = CGRectMake(padXRealValue * 3 - timeLabelFour.frame.size.width / 2, timeY, timeLabelFour.frame.size.width, timeLabelFour.frame.size.height);
    [self addSubview:timeLabelFour];
    
    UILabel *timeLabelFive = [[UILabel alloc] init];
    timeLabelFive.backgroundColor = [UIColor clearColor];
    timeLabelFive.text = @"15:00";
    timeLabelFive.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
    timeLabelFive.font = self.font;
    [timeLabelFive sizeToFit];
    timeLabelFive.frame = CGRectMake(self.xWidth - timeLabelFive.frame.size.width, timeY, timeLabelFive.frame.size.width, timeLabelFive.frame.size.height);
    [self addSubview:timeLabelFive];
}

#pragma mark - 长按就开始生成十字线
- (void)gestureRecognizerHandle:(UILongPressGestureRecognizer *)longResture {
    _touchViewPoint = [longResture locationInView:self];
    // 手指长按开始时更新界面
    if (longResture.state == UIGestureRecognizerStateBegan) {
        if (self.finishUpdateBlock) {
            self.finishUpdateBlock(self);
        }
    }
    // 手指移动时候开始显示十字线
    if (longResture.state == UIGestureRecognizerStateChanged) {
        [self isTimePointWithPoint:_touchViewPoint];
    }
    // 手指离开的时候移除十字线
    if (longResture.state == UIGestureRecognizerStateEnded) {
        [_moveLineOne removeFromSuperview];
        [_moveLineTwo removeFromSuperview];
        [_moveLinePoint removeFromSuperview];
        [self.movePopUpView removeFromSuperview];
        _moveLineOne = nil;
        _moveLineTwo = nil;
        _moveLinePoint = nil;
        self.movePopUpView = nil;
    }
}

#pragma mark 判断并在十字线上显示提示信息
- (void)isTimePointWithPoint:(CGPoint)point {
    CGFloat itemPointX = 0;
    for (NSString *item in _pointArray) {
        CGPoint itemPoint = CGPointFromString(item);
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = (int)point.x;
        if (itemX == pointX || pointX - itemX <= self.timePointWidth/2) {
            _moveLineOne.frame = CGRectMake(itemPointX, _moveLineOne.frame.origin.y, _moveLineOne.frame.size.width, _moveLineOne.frame.size.height);
            _moveLineTwo.frame = CGRectMake(_moveLineTwo.frame.origin.x, itemPoint.y, _moveLineTwo.frame.size.width, _moveLineTwo.frame.size.height);
            _moveLinePoint.frame = CGRectMake(itemPoint.x - KMoveLinePointWidth/2, itemPoint.y - KMoveLinePointWidth/2, KMoveLinePointWidth, KMoveLinePointWidth);
            //弹出提示视图
            CGFloat moveViewX = self.movePopUpView.frame.origin.x;
            // 如果滑动到了左半边则提示向右跳转
            if ((_aboveBoxView.frame.size.width - itemPointX) > _aboveBoxView.frame.size.width / 2) {
                moveViewX = _aboveBoxView.frame.size.width - self.movePopUpView.frame.size.width;
            } else {
                moveViewX = 0;
            }
            self.movePopUpView.frame = CGRectMake(moveViewX, self.movePopUpView.frame.origin.y, self.movePopUpView.frame.size.width, self.movePopUpView.frame.size.height);
            // 弹框数据显示
            self.movePopUpView.dic = [self.dataArray objectAtIndex:[_pointArray indexOfObject:item]];
            
            break;
        }
    }
}

#pragma mark 画分时图
- (void)drawLine {
    if (!self.dataArray.count) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // 处理需要显示的分时数据
        [self handleDataWith:self.dataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 开始画分时图
            [self drawBoxWithLine];
            // 清除旧的k线
            if (self.timeLineOldArray.count > 0 && _isUpdate) {
                for (SJTimeLines *line in self.timeLineOldArray) {
                    [line removeFromSuperview];
                }
            }
            self.timeLineOldArray = [self.timeLineArray copy];
        });
    });
}

#pragma mark - 处理需要显示的K线
- (void)handleDataWith:(NSArray *)data {
    self.priceMaxValue = 0;
    self.priceMinValue = 9999;
    self.netChangeRatioMaxValue = 0;
    self.netChangeRatioMinValue = 9999;
    self.volMaxValue = 0;
    for (NSDictionary *tmpDic in data) {
        if (!tmpDic) {
            continue;
        }
        // 价格的最大值和最小值
        if ([tmpDic[@"price"] floatValue] > self.priceMaxValue) {
            self.priceMaxValue = [tmpDic[@"price"] floatValue];
        }
        if ([tmpDic[@"price"] floatValue] < self.priceMinValue) {
            self.priceMinValue = [tmpDic[@"price"] floatValue];
        }
        // 成交量的最大值
        if ([tmpDic[@"volume"] floatValue] > self.volMaxValue) {
            self.volMaxValue = [tmpDic[@"volume"] floatValue];
        }
        // 涨幅的最大值和最小值
        if ([tmpDic[@"netChangeRatio"] floatValue] > self.netChangeRatioMaxValue) {
            self.netChangeRatioMaxValue = [tmpDic[@"netChangeRatio"] floatValue];
        }
        if ([tmpDic[@"netChangeRatio"] floatValue] < self.netChangeRatioMinValue) {
            self.netChangeRatioMinValue = [tmpDic[@"netChangeRatio"] floatValue];
        }
    }
}

#pragma mark - 在框框里画线
- (void)drawBoxWithLine {
    [self changeMaxAndMinValue];
    // 分割线数值
    CGFloat padPriceValue = (self.priceMaxValue - self.priceMinValue) / 4; // 价格均分值
    CGFloat padNetChangeRatioValue = fabs(self.netChangeRatioMinValue) / 2; // 涨跌幅均分值
    CGFloat padRealValue = self.yHeight / 4;
    for (int i = 0; i < 5; i++) {
        CGFloat y = self.yHeight - padRealValue * i;
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = [[NSString alloc] initWithFormat:@"%.2f", padPriceValue * i + self.priceMinValue];
        leftLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
        leftLabel.font = self.font;
        leftLabel.backgroundColor = [UIColor clearColor];
        [leftLabel sizeToFit];
        if (i == 0) {
            leftLabel.frame = CGRectMake(Padding, y - leftLabel.frame.size.height, leftLabel.frame.size.width, leftLabel.frame.size.height);
        } else if (i == 4) {
            leftLabel.frame = CGRectMake(Padding, 0, leftLabel.frame.size.width, leftLabel.frame.size.height);
        } else {
            leftLabel.frame = CGRectMake(Padding, y - leftLabel.frame.size.height / 2, leftLabel.frame.size.width, leftLabel.frame.size.height);
        }
        [_aboveBoxView addSubview:leftLabel];
        [self.timeLineArray addObject:leftLabel];
        
        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.text = [NSString stringWithFormat:@"%.2f%@", padNetChangeRatioValue * i + self.netChangeRatioMinValue, @"%"];
        rightLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
        rightLabel.font = self.font;
        rightLabel.backgroundColor = [UIColor clearColor];
        [rightLabel sizeToFit];
        if (i == 0) {
            rightLabel.frame = CGRectMake(self.xWidth - rightLabel.frame.size.width - Padding, y - rightLabel.frame.size.height, rightLabel.frame.size.width, rightLabel.frame.size.height);
        } else if (i == 4) {
            rightLabel.frame = CGRectMake(self.xWidth - rightLabel.frame.size.width - Padding, 0, rightLabel.frame.size.width, rightLabel.frame.size.height);
        } else {
            rightLabel.frame = CGRectMake(self.xWidth - rightLabel.frame.size.width - Padding, y - rightLabel.frame.size.height / 2, rightLabel.frame.size.width, rightLabel.frame.size.height);
        }
        [_aboveBoxView addSubview:rightLabel];
        [self.timeLineArray addObject:rightLabel];
    }
    
    // 开始画均线
    NSArray *avgTempArray = [self changePointWithData:self.dataArray];
    SJTimeLines *avgLine = [[SJTimeLines alloc] initWithFrame:CGRectMake(0, 0, _aboveBoxView.frame.size.width, _aboveBoxView.frame.size.height)];
    avgLine.hexColor = @"#FF9900";
    avgLine.points = avgTempArray;
    avgLine.lineWidth = 0.5;
    [_aboveBoxView addSubview:avgLine];
    [self.timeLineArray addObject:avgLine];
    // 开始画分时线
    NSArray *timeTempArray = [self changeTimePointWithData:self.dataArray];
    SJTimeLines *timeLine = [[SJTimeLines alloc] initWithFrame:CGRectMake(0, 0, _aboveBoxView.frame.size.width, _aboveBoxView.frame.size.height)];
    timeLine.hexColor = @"#3299CC";
    timeLine.points = timeTempArray;
    timeLine.isTimeLine = YES;
    timeLine.lineWidth = 0.5;
    [_aboveBoxView addSubview:timeLine];
    [self.timeLineArray addObject:timeLine];
    // 开始画成交量
    NSArray *volTempArray = [self changeVolumePointWithData:self.dataArray]; // 换算成实际成交量坐标数组
    SJTimeLines *volLine = [[SJTimeLines alloc] initWithFrame:CGRectMake(0, 0, _bottomBoxView.frame.size.width, _bottomBoxView.frame.size.height)];
    volLine.points = volTempArray;
    volLine.lineWidth = self.timePointWidth;
    volLine.isVol = YES;
    [_bottomBoxView addSubview:volLine];
    [self.timeLineArray addObject:volLine];
    _volMaxValueLabel.text = [NSString stringWithFormat:@"%.0f手", self.volMaxValue/100];
}

#pragma mark - 改变最大值和最小值
- (void)changeMaxAndMinValue {
    if (self.priceMaxValue - self.preClose > self.preClose - self.priceMinValue) {
        self.priceMinValue = self.preClose * 2 - self.priceMaxValue;
    } else {
        self.priceMaxValue = self.preClose * 2 - self.priceMinValue;
    }
    
    if (fabs(self.netChangeRatioMaxValue) > fabs(self.netChangeRatioMinValue)) {
        self.netChangeRatioMinValue = -fabs(self.netChangeRatioMaxValue);
    } else {
        self.netChangeRatioMinValue = -fabs(self.netChangeRatioMinValue);
    }
}

#pragma mark - 把股市数据换算成实际的点坐标数组
- (NSArray *)changePointWithData:(NSArray *)data {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat pointStartX = 0.0f; // 起始点坐标
    for (NSDictionary *tmpDic in data) {
        CGFloat currentValue = [tmpDic[@"avgPrice"] floatValue];
        // 换算成实际的坐标
        CGFloat currentPointY = self.yHeight * (1 - (currentValue - self.priceMinValue) / (self.priceMaxValue - self.priceMinValue));
        CGPoint currentPoint = CGPointMake(pointStartX, currentPointY);
        [tempArray addObject:NSStringFromCGPoint(currentPoint)];
        // 生成下一个点的x轴
        pointStartX += self.timePointWidth;
    }
    return tempArray;
}

- (NSArray *)changeTimePointWithData:(NSArray *)data {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    _pointArray = [NSMutableArray array];
    CGFloat pointStartX = 0.0f; // 起始点坐标
    for (NSDictionary *tmpDic in data) {
        CGFloat currentValue = [tmpDic[@"price"] floatValue];
        // 换算成实际的坐标
        CGFloat currentPointY = self.yHeight * (1 - (currentValue - self.priceMinValue) / (self.priceMaxValue - self.priceMinValue));
        CGPoint currentPoint = CGPointMake(pointStartX, currentPointY);
        [tempArray addObject:NSStringFromCGPoint(currentPoint)];
        // 生成下一个点的x轴
        pointStartX += self.timePointWidth;
    }
    _pointArray = tempArray;
    return tempArray;
}

- (NSArray *)changeVolumePointWithData:(NSArray *)data {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat pointStartX = 0.0f; // 起始点坐标
    for (NSDictionary *tmpDic in data) {
        CGFloat volumevalue = [tmpDic[@"volume"] floatValue];// 得到每份成交量
        CGFloat yHeight = self.volMaxValue; // y的成交量高度
        CGFloat yViewHeight = _bottomBoxView.frame.size.height ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY = yViewHeight * (1 - volumevalue / yHeight);
        CGPoint volumePoint = CGPointMake(pointStartX, volumePointY); // 成交量换算为实际坐标值
        CGPoint volumePointStart = CGPointMake(pointStartX, yViewHeight);
        // 实际坐标组装为数组
        NSArray *item = [[NSArray alloc] initWithObjects:
                         NSStringFromCGPoint(volumePointStart),
                         NSStringFromCGPoint(volumePoint),
                         tmpDic[@"price"],
                         tmpDic[@"preClose"],
                         nil];
        [tempArray addObject:item]; // 把坐标添加进新数组
        item = Nil;
        pointStartX += self.timePointWidth; // 生成下一个点的x轴
    }
    SJLog(@"处理完成");
    return tempArray;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end

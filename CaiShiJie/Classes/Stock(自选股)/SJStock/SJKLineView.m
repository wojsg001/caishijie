//
//  SJKLineView.m
//  QuartzDemo
//
//  Created by user on 16/9/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJKLineView.h"
#import "UIColor+helper.h"
#import "Masonry.h"
#import "SJKLines.h"
#import "SJStockPopUpView.h"
#import <BlocksKit/NSArray+BlocksKit.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define Padding 2

@interface SJKLineView ()

@property (nonatomic, strong) UIView *aboveBoxView; // K线图控件
@property (nonatomic, strong) UIView *bottomBoxView; // 成交量控件
@property (nonatomic, strong) NSMutableArray *pointArray; // K线所有坐标数组
@property (nonatomic, strong) UILabel *MA5Label;
@property (nonatomic, strong) UILabel *MA10Label;
@property (nonatomic, strong) UILabel *MA20Label;
@property (nonatomic, strong) UILabel *startDateLabel;
@property (nonatomic, strong) UILabel *endDateLabel;
@property (nonatomic, strong) UILabel *volMaxValueLabel; // 显示成交量最大值
@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, assign) BOOL isUpdateFinish;
@property (nonatomic, strong) NSMutableArray *kLineArray; // K线数组
@property (nonatomic, strong) NSMutableArray *kLineOldArray; // K线旧数组
@property (nonatomic, strong) UIView *moveLineOne;// 手指按下后显示的两根十字线
@property (nonatomic, strong) UIView *moveLineTwo;
@property (nonatomic, strong) SJStockPopUpView *moveLineView;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, assign) CGPoint touchViewPoint;
@property (nonatomic, assign) BOOL isPinch;

@end

@implementation SJKLineView

- (SJStockPopUpView *)moveLineView {
    if (!_moveLineView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJStockUI" owner:nil options:nil];
        _moveLineView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJStockPopUpView class]];
        }];
        _moveLineView.layer.cornerRadius = 4;
        _moveLineView.layer.shadowColor = [UIColor blackColor].CGColor;
        _moveLineView.layer.shadowRadius = 3;
        _moveLineView.layer.shadowOpacity = 0.2;
        _moveLineView.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return _moveLineView;
}

- (NSMutableArray *)kLineArray {
    if (!_kLineArray) {
        _kLineArray = [NSMutableArray array];
    }
    return _kLineArray;
}

- (NSMutableArray *)kLineOldArray {
    if (!_kLineOldArray) {
        _kLineOldArray = [NSMutableArray array];
    }
    return _kLineOldArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSetting];
    }
    return self;
}

- (void)initSetting {
    self.xWidth = self.frame.size.width; // K线图宽度
    self.yHeight = 150; // K线图高度
    self.bottomBoxHeight = 60; // 底部成交量图的高度
    self.kLineWidth = 5; // K线实体的宽度
    self.kLinePadding = 1; // K线实体的间隔
    self.font = [UIFont systemFontOfSize:9];
    _isUpdate = NO;
    _isUpdateFinish = YES;
    _isPinch = NO;
    
    self.finishUpdateBlock = ^(id self) {
        [self updateNib];
    };
}

- (void)start {
    [self drawBox];
    [self drawLine];
//    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(drawLine) object:nil];
//    [_thread start];
}

- (void)update {
    if (self.kLineWidth > 20) {
        self.kLineWidth = 20;
        return;
    }
    if (self.kLineWidth < 1) {
        self.kLineWidth = 1;
        return;
    }
    _isUpdate = YES;
    
    self.clearsContextBeforeDrawing = YES;
    [self drawLine];
}

- (void)updateSelf {
    if (_isUpdateFinish) {
        if (self.kLineWidth > 20) {
            self.kLineWidth = 20;
            return;
        }
        if (self.kLineWidth < 1) {
            self.kLineWidth = 1;
            return;
        }
        _isUpdateFinish = NO;
        _isUpdate = YES;
        self.dataArray = nil;
        _pointArray = nil;

        self.clearsContextBeforeDrawing = YES;
        [self drawLine];
    }
}

#pragma mark 画框框和平均线
- (void)drawBox {
    WS(weakSelf);
    // 画K线图的框框
    if (_aboveBoxView == nil) {
        _aboveBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.xWidth, self.yHeight)];
        _aboveBoxView.backgroundColor = [UIColor whiteColor];
        _aboveBoxView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha].CGColor;
        _aboveBoxView.layer.borderWidth = 0.5f;
        _aboveBoxView.userInteractionEnabled = YES;
        [self addSubview:_aboveBoxView];
        // 添加手指捏合手势，放大或缩小k线图
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(touchBoxAction:)];
        [_aboveBoxView addGestureRecognizer:_pinchGesture];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        [longPressGestureRecognizer setMinimumPressDuration:0.3f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        [_aboveBoxView addGestureRecognizer:longPressGestureRecognizer];
    }
    
    // 画成交量框框
    if (_bottomBoxView == nil) {
        _bottomBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, _aboveBoxView.frame.size.height + 20, self.xWidth, self.bottomBoxHeight)];
        _bottomBoxView.backgroundColor = [UIColor whiteColor];
        _bottomBoxView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha].CGColor;
        _bottomBoxView.layer.borderWidth = 0.5f;
        _bottomBoxView.userInteractionEnabled = YES;
        [self addSubview:_bottomBoxView];
    }
    
    // 把显示开始结束日期放在成交量的底部左右两侧
    // 显示开始日期控件
    if (_startDateLabel == nil) {
        _startDateLabel = [[UILabel alloc] init];
        _startDateLabel.font = self.font;
        _startDateLabel.text = @"--";
        _startDateLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
        _startDateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_startDateLabel];
        [_startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.aboveBoxView.mas_left).offset(0);
            make.top.equalTo(weakSelf.aboveBoxView.mas_bottom).offset(5);
        }];
    }
    // 显示结束日期控件
    if (_endDateLabel == nil) {
        _endDateLabel = [[UILabel alloc] init];
        _endDateLabel.font = self.font;
        _endDateLabel.text = @"--";
        _endDateLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
        _endDateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_endDateLabel];
        [_endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.aboveBoxView.mas_right).offset(0);
            make.top.equalTo(weakSelf.aboveBoxView.mas_bottom).offset(5);
        }];
    }
    // 显示成交量最大值
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
    // MA5均线价格显示控件
    if (_MA5Label == nil) {
        _MA5Label = [[UILabel alloc] init];
        _MA5Label.backgroundColor = [UIColor clearColor];
        _MA5Label.font = self.font;
        _MA5Label.text = @"MA5";
        _MA5Label.textColor = [UIColor colorWithHexString:@"#18b5ee" withAlpha:self.alpha];
        [self addSubview:_MA5Label];
        [_MA5Label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.aboveBoxView.mas_left).offset(30);
            make.top.equalTo(weakSelf.aboveBoxView.mas_top).offset(5);
        }];
    }
    // MA10均线价格显示控件
    if (_MA10Label == nil) {
        _MA10Label = [[UILabel alloc] init];
        _MA10Label.backgroundColor = [UIColor clearColor];
        _MA10Label.font = self.font;
        _MA10Label.text = @"MA10";
        _MA10Label.textColor = [UIColor colorWithHexString:@"#FF9900" withAlpha:self.alpha];
        [self addSubview:_MA10Label];
        [_MA10Label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.aboveBoxView.mas_top).offset(5);
            make.centerX.mas_equalTo(weakSelf.aboveBoxView);
        }];
    }
    // MA20均线价格显示控件
    if (_MA20Label == nil) {
        _MA20Label = [[UILabel alloc] init];
        _MA20Label.backgroundColor = [UIColor clearColor];
        _MA20Label.font = self.font;
        _MA20Label.text = @"MA20";
        _MA20Label.textColor = [UIColor colorWithHexString:@"#FF00FF" withAlpha:self.alpha];
        [self addSubview:_MA20Label];
        [_MA20Label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.aboveBoxView.mas_right).offset(-30);
            make.top.equalTo(weakSelf.aboveBoxView.mas_top).offset(5);
        }];
    }
    
    if (!_isUpdate) {
        // 分割线
        CGFloat padRealValue = _aboveBoxView.frame.size.height / 5;
        for (int i = 1; i < 5; i++) {
            CGFloat y = padRealValue * i;
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, _aboveBoxView.frame.size.width, 0.5)];
            line.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:self.alpha];
            [_aboveBoxView addSubview:line];
        }
    }
}

#pragma mark 手指捏合动作
- (void)touchBoxAction:(UIPinchGestureRecognizer *)pGesture {
    _isPinch = NO;
    //NSLog(@"状态：%li==%f", (long)pGesture.state, pGesture.scale);
    if (pGesture.state == UIGestureRecognizerStateChanged && _isUpdateFinish) {
        if (pGesture.scale > 1) {
            // 放大手势
            self.kLineWidth++;
            [self updateSelf];
        } else {
            // 缩小手势
            self.kLineWidth--;
            [self updateSelf];
        }
    }
    if (pGesture.state == UIGestureRecognizerStateEnded) {
        _isUpdateFinish = YES;
    }
}

#pragma mark 长按就开始生成十字线
- (void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)longResture {
    _isPinch = YES;
    //NSLog(@"gestureRecognizerHandle%li",(long)longResture.state);
    _touchViewPoint = [longResture locationInView:_aboveBoxView];
    // 手指长按开始时更新界面
    if (longResture.state == UIGestureRecognizerStateBegan) {
        if (_finishUpdateBlock && _isPinch) {
            _finishUpdateBlock(self);
        }
    }
    // 手指移动时候开始显示十字线
    if (longResture.state == UIGestureRecognizerStateChanged) {
        [self isKPointWithPoint:_touchViewPoint];
    }
    // 手指离开的时候移除十字线
    if (longResture.state == UIGestureRecognizerStateEnded) {
        _MA5Label.text = @"MA5";
        [_MA5Label sizeToFit];
        _MA10Label.text = @"MA10";
        [_MA10Label sizeToFit];
        _MA20Label.text = @"MA20";
        [_MA20Label sizeToFit];
        [_moveLineOne removeFromSuperview];
        [_moveLineTwo removeFromSuperview];
        [self.moveLineView removeFromSuperview];
        _moveLineOne = nil;
        _moveLineTwo = nil;
        self.moveLineView = nil;
        _isPinch = NO;
    }
}

#pragma mark 判断并在十字线上显示提示信息
- (void)isKPointWithPoint:(CGPoint)point {
    CGFloat itemPointX = 0;
    for (NSArray *item in _pointArray) {
        CGPoint itemPoint = CGPointFromString([item objectAtIndex:3]); // 收盘价的坐标
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = (int)point.x;
        if (itemX == pointX || point.x - itemX <= self.kLineWidth/2) {
            _moveLineOne.frame = CGRectMake(itemPointX, _moveLineOne.frame.origin.y, _moveLineOne.frame.size.width, _moveLineOne.frame.size.height);
            _moveLineTwo.frame = CGRectMake(_moveLineTwo.frame.origin.x, itemPoint.y, _moveLineTwo.frame.size.width, _moveLineTwo.frame.size.height);
            // 横向提示控件
            CGFloat moveLineX = self.moveLineView.frame.origin.x;
            // 如果滑动到了左半边则提示向右跳转
            if ((_aboveBoxView.frame.size.width - itemPointX) > _aboveBoxView.frame.size.width / 2) {
                moveLineX = _aboveBoxView.frame.size.width - self.moveLineView.frame.size.width;
            } else {
                moveLineX = 0;
            }
            self.moveLineView.frame = CGRectMake(moveLineX, self.moveLineView.frame.origin.y, self.moveLineView.frame.size.width, self.moveLineView.frame.size.height);
            // 弹框数据显示
            self.moveLineView.item = [self.dataArray objectAtIndex:[_pointArray indexOfObject:item]];
            // 均线值显示
            _MA5Label.text = [[NSString alloc] initWithFormat:@"MA5:%.2f",[[item objectAtIndex:5] floatValue]];
            [_MA5Label sizeToFit];
            _MA10Label.text = [[NSString alloc] initWithFormat:@"MA10:%.2f",[[item objectAtIndex:6] floatValue]];
            [_MA10Label sizeToFit];
            _MA20Label.text = [[NSString alloc] initWithFormat:@"MA20:%.2f",[[item objectAtIndex:7] floatValue]];
            [_MA20Label sizeToFit];
            break;
        }
    }
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
        _moveLineTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _aboveBoxView.frame.size.width, 0.5)];
        _moveLineTwo.backgroundColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
        _moveLineTwo.hidden = YES;
        [self addSubview:_moveLineTwo];
    }
    
    _moveLineOne.frame = CGRectMake(_touchViewPoint.x, 0, 0.5, _bottomBoxView.frame.size.height + _bottomBoxView.frame.origin.y);
    _moveLineTwo.frame = CGRectMake(0, _touchViewPoint.y, _aboveBoxView.frame.size.width, 0.5);
    _moveLineOne.hidden = NO;
    _moveLineTwo.hidden = NO;
    self.moveLineView.frame = CGRectMake(0, 20, 95, 115);
    self.moveLineView.hidden = NO;
    [self addSubview:self.moveLineView];
    
    [self isKPointWithPoint:_touchViewPoint];
}

#pragma mark 画k线
- (void)drawLine {
    self.kCount = self.xWidth / (self.kLineWidth + self.kLinePadding); // K线中实体的总数
    if (!self.originalDataArray.count) {
        return;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // 处理需要显示的K线
        [self handleDataWith:self.originalDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 开始画K线图
            [self drawBoxWithKline];
            // 清除旧的k线
            if (self.kLineOldArray.count > 0 && _isUpdate) {
                for (SJKLines *line in self.kLineOldArray) {
                    [line removeFromSuperview];
                }
            }
            self.kLineOldArray = [self.kLineArray copy];
            _isUpdateFinish = YES;
        });
    });
}

#pragma mark - 处理需要显示的K线
- (void)handleDataWith:(NSArray *)lines {
    self.maxValue = 0;
    self.minValue = 9999;
    self.volMaxValue = 0;
    NSMutableArray *dataArray = [NSMutableArray array];
    NSArray *newArray = lines;
    newArray = [newArray objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.kCount>=newArray.count?newArray.count:self.kCount)]];
    //NSLog(@"newArray:%@", newArray);
    for (NSInteger idx = newArray.count - 1; idx >= 0; idx--) {
        NSDictionary *tmpDic = [newArray objectAtIndex:idx];
        if (!tmpDic) {
            continue;
        }
        // 收盘价的最大值和最小值
        if ([tmpDic[@"kline"][@"high"] floatValue] > self.maxValue) {
            self.maxValue = [tmpDic[@"kline"][@"high"] floatValue];
        }
        if ([tmpDic[@"kline"][@"low"] floatValue] < self.minValue) {
            self.minValue = [tmpDic[@"kline"][@"low"] floatValue];
        }
        // 成交量的最大值
        if ([tmpDic[@"kline"][@"volume"] floatValue] > self.volMaxValue) {
            self.volMaxValue = [tmpDic[@"kline"][@"volume"] floatValue];
        }

        NSMutableArray *item = [[NSMutableArray alloc] init];
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"kline"][@"open"]]];   // open
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"kline"][@"high"]]];   // high
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"kline"][@"low"]]];    // low
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"kline"][@"close"]]];  // close
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"kline"][@"volume"]]]; // volume
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"ma5"][@"avgPrice"]]]; // MA5
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"ma10"][@"avgPrice"]]];// MA10
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"ma20"][@"avgPrice"]]];// MA20
        [item addObject:[self fromAnyTypeToStringWith:tmpDic[@"kline"][@"netChangeRatio"]]]; // 涨跌幅
        [item addObject:[self dateStringWithNumber:tmpDic[@"date"]]]; // 日期
        [dataArray addObject:item];
    }
    if (dataArray.count == 0) {
        // 无数据
        return;
    }
    self.dataArray = dataArray;
}

- (NSString *)fromAnyTypeToStringWith:(id)object {
    return [NSString stringWithFormat:@"%@", object];
}

- (NSString *)dateStringWithNumber:(NSNumber *)time {
    NSString *tmpStr = [NSString stringWithFormat:@"%@",time];
    return [NSString stringWithFormat:@"%@-%@-%@", [tmpStr substringWithRange:NSMakeRange(0, 4)], [tmpStr substringWithRange:NSMakeRange(4, 2)], [tmpStr substringWithRange:NSMakeRange(6, 2)]];
}

#pragma mark 在框框里画k线
- (void)drawBoxWithKline {
    [self changeMaxAndMinValue];
    // 平均线
    CGFloat padValue = (self.maxValue - self.minValue) / 5;
    CGFloat padRealValue = _aboveBoxView.frame.size.height / 5;
    for (int i = 0; i < 6; i++) {
        CGFloat y = _aboveBoxView.frame.size.height - padRealValue * i;
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = [[NSString alloc] initWithFormat:@"%.2f", padValue * i + self.minValue];
        leftLabel.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:self.alpha];
        leftLabel.font = self.font;
        leftLabel.backgroundColor = [UIColor clearColor];
        [leftLabel sizeToFit];
        if (i == 0) {
            leftLabel.frame = CGRectMake(Padding, y - leftLabel.frame.size.height, leftLabel.frame.size.width, leftLabel.frame.size.height);
        } else if (i == 5) {
            leftLabel.frame = CGRectMake(Padding, 0, leftLabel.frame.size.width, leftLabel.frame.size.height);
        } else {
            leftLabel.frame = CGRectMake(Padding, y - leftLabel.frame.size.height / 2, leftLabel.frame.size.width, leftLabel.frame.size.height);
        }
        
        [_aboveBoxView addSubview:leftLabel];
        [self.kLineArray addObject:leftLabel];
    }
    
    // 开始画连接线
    // x轴从0到框框的宽度_aboveBoxView.frame.size.width变化，y轴为每个间隔的连线，如：今天的点连接明天的点
    // MA5
    [self drawMAWithIndex:5 andColor:@"#18b5ee"];
    // MA10
    [self drawMAWithIndex:6 andColor:@"#FF9900"];
    // MA20
    [self drawMAWithIndex:7 andColor:@"#FF00FF"];
    
    // 开始画连K线
    // x轴从0到框框的宽度_aboveBoxView.frame.size.width变化，y轴为每个间隔的连线，如：今天的点连接明天的点
    NSArray *kTempArray = [self changeKPointWithData:self.dataArray]; // 换算成实际每天收盘价坐标数组
    SJKLines *kLine = [[SJKLines alloc] initWithFrame:CGRectMake(0, 0, _aboveBoxView.frame.size.width, _aboveBoxView.frame.size.height)];
    kLine.points = kTempArray;
    kLine.lineWidth = self.kLineWidth;
    kLine.isK = YES;
    [_aboveBoxView addSubview:kLine];
    [self.kLineArray addObject:kLine];
    
    // 开始画连成交量
    NSArray *volTempArray = [self changeVolumePointWithData:self.dataArray]; // 换算成实际成交量坐标数组
    SJKLines *volLine = [[SJKLines alloc] initWithFrame:CGRectMake(0, 0, _bottomBoxView.frame.size.width, _bottomBoxView.frame.size.height)];
    volLine.points = volTempArray;
    volLine.lineWidth = self.kLineWidth;
    volLine.isK = YES;
    volLine.isVol = YES;
    [_bottomBoxView addSubview:volLine];
    _volMaxValueLabel.text = [self changePrice:self.volMaxValue/100];
    [self.kLineArray addObject:volLine];
}

// 数值变化
- (NSString *)changePrice:(CGFloat)price {
    CGFloat newPrice = 0;
    NSString *danwei = @"万";
    if ((int)price>10000) {
        newPrice = price / 10000 ;
    } else if ((int)price>10000000) {
        newPrice = price / 10000000 ;
        danwei = @"千万";
    } else if ((int)price>100000000) {
        newPrice = price / 100000000 ;
        danwei = @"亿";
    }
    NSString *newstr = [[NSString alloc] initWithFormat:@"%.2f%@",newPrice,danwei];
    return newstr;
}

#pragma mark 改变最大值和最小值
- (void)changeMaxAndMinValue {
    CGFloat padValue = (self.maxValue - self.minValue) / 5;
    self.maxValue += padValue;
    self.minValue -= padValue;
}

#pragma mark 画各种均线
- (void)drawMAWithIndex:(int)index andColor:(NSString*)color {
    NSArray *tempArray = [self changePointWithData:self.dataArray andMA:index]; // 换算成实际坐标数组
    SJKLines *line = [[SJKLines alloc] initWithFrame:CGRectMake(0, 0, _aboveBoxView.frame.size.width, _aboveBoxView.frame.size.height)];
    line.hexColor = color;
    line.points = tempArray;
    line.isK = NO;
    [_aboveBoxView addSubview:line];
    [self.kLineArray addObject:line];
}

#pragma mark 把股市数据换算成实际的点坐标数组  MA = 5 为MA5 MA=6 MA10  MA7 = MA20
- (NSArray *)changePointWithData:(NSArray*)data andMA:(int)MAIndex {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat pointStartX = 0.0f; // 起始点坐标
    for (NSArray *item in data) {
        CGFloat currentValue = [[item objectAtIndex:MAIndex] floatValue]; // 得到前五天、前十天、前二十天的均价价格
        // 换算成实际的坐标
        CGFloat currentPointY = _aboveBoxView.frame.size.height - ((currentValue - self.minValue) / (self.maxValue - self.minValue) * _aboveBoxView.frame.size.height);
        CGPoint currentPoint = CGPointMake(pointStartX, currentPointY); // 换算到当前的坐标值
        [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        pointStartX += self.kLineWidth + self.kLinePadding; // 生成下一个点的x轴
    }
    return tempArray;
}

#pragma mark 把股市数据换算成实际的点坐标数组
- (NSArray *)changeKPointWithData:(NSArray*)data {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    _pointArray = [[NSMutableArray alloc] init];
    CGFloat pointStartX = self.kLineWidth / 2; // 起始点坐标
    for (NSArray *item in data) {
        CGFloat heightvalue = [[item objectAtIndex:1] floatValue];// 得到最高价
        CGFloat lowvalue = [[item objectAtIndex:2] floatValue];// 得到最低价
        CGFloat openvalue = [[item objectAtIndex:0] floatValue];// 得到开盘价
        CGFloat closevalue = [[item objectAtIndex:3] floatValue];// 得到收盘价
        CGFloat yHeight = self.maxValue - self.minValue ; // y的价格高度
        CGFloat yViewHeight = _aboveBoxView.frame.size.height ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat heightPointY = yViewHeight * (1 - (heightvalue - self.minValue) / yHeight);
        CGPoint heightPoint =  CGPointMake(pointStartX, heightPointY); // 最高价换算为实际坐标值
        CGFloat lowPointY = yViewHeight * (1 - (lowvalue - self.minValue) / yHeight);;
        CGPoint lowPoint =  CGPointMake(pointStartX, lowPointY); // 最低价换算为实际坐标值
        CGFloat openPointY = yViewHeight * (1 - (openvalue - self.minValue) / yHeight);;
        CGPoint openPoint =  CGPointMake(pointStartX, openPointY); // 开盘价换算为实际坐标值
        CGFloat closePointY = yViewHeight * (1 - (closevalue - self.minValue) / yHeight);;
        CGPoint closePoint =  CGPointMake(pointStartX, closePointY); // 收盘价换算为实际坐标值
        // 实际坐标组装为数组
        NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                 NSStringFromCGPoint(heightPoint),
                                 NSStringFromCGPoint(lowPoint),
                                 NSStringFromCGPoint(openPoint),
                                 NSStringFromCGPoint(closePoint),
                                 [item objectAtIndex:9], // 保存日期时间
                                 [item objectAtIndex:3], // 收盘价
                                 [item objectAtIndex:5], // MA5
                                 [item objectAtIndex:6], // MA10
                                 [item objectAtIndex:7], // MA20
                                 nil];
        [tempArray addObject:currentArray]; // 把坐标添加进新数组
        currentArray = Nil;
        pointStartX += self.kLineWidth + self.kLinePadding; // 生成下一个点的x轴
        
        // 在成交量视图左右下方显示开始和结束日期
        if ([data indexOfObject:item] == 0) {
            _startDateLabel.text = [item objectAtIndex:9];
        }
        if ([data indexOfObject:item] == data.count - 1) {
            _endDateLabel.text = [item objectAtIndex:9];
        }
    }
    _pointArray = tempArray;
    return tempArray;
}

#pragma mark 把股市数据换算成成交量的实际坐标数组
- (NSArray *)changeVolumePointWithData:(NSArray*)data {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat pointStartX = self.kLineWidth/2; // 起始点坐标
    for (NSArray *item in data) {
        CGFloat volumevalue = [[item objectAtIndex:4] floatValue];// 得到每份成交量
        CGFloat yHeight = self.volMaxValue; // y的成交量高度
        CGFloat yViewHeight = _bottomBoxView.frame.size.height ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY = yViewHeight * (1 - volumevalue / yHeight);
        CGPoint volumePoint =  CGPointMake(pointStartX, volumePointY); // 成交量换算为实际坐标值
        CGPoint volumePointStart = CGPointMake(pointStartX, yViewHeight);
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = [[item objectAtIndex:0] floatValue];// 得到开盘价
        CGFloat closevalue = [[item objectAtIndex:3] floatValue];// 得到收盘价
        CGPoint openPoint = CGPointMake(pointStartX, closevalue); // 开盘价换算为实际坐标值
        CGPoint closePoint = CGPointMake(pointStartX, openvalue); // 收盘价换算为实际坐标值
        // 实际坐标组装为数组
        NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                 NSStringFromCGPoint(volumePointStart),
                                 NSStringFromCGPoint(volumePoint),
                                 NSStringFromCGPoint(openPoint),
                                 NSStringFromCGPoint(closePoint),
                                 nil];
        [tempArray addObject:currentArray]; // 把坐标添加进新数组
        currentArray = Nil;
        pointStartX += self.kLineWidth + self.kLinePadding; // 生成下一个点的x轴
    }
    NSLog(@"处理完成");
    return tempArray;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end

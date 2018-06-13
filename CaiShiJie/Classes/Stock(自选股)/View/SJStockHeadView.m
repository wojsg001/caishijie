//
//  SJStockHeadView.m
//  CaiShiJie
//
//  Created by user on 16/9/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJStockHeadView.h"
#import "SJStockDayLineViewController.h"
#import "SJStockWeekLineViewController.h"
#import "SJStockMonthLineViewController.h"
#import "SJStockTimeLineViewController.h"

@interface SJStockHeadView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhangdieLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhangdiefuLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesterdayCloseLabel;
@property (weak, nonatomic) IBOutlet UILabel *volLabel;
@property (weak, nonatomic) IBOutlet UILabel *exchangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *higheLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *tradeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *neipanLabel;
@property (weak, nonatomic) IBOutlet UILabel *waipanLabel;
@property (weak, nonatomic) IBOutlet UILabel *shizhiLabel;
@property (weak, nonatomic) IBOutlet UILabel *shiyinglvLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhenfuLabel;
@property (weak, nonatomic) IBOutlet UILabel *liutongshizhiLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *dayButton;
@property (weak, nonatomic) IBOutlet UIButton *weekButton;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) UIViewController *lastSelectedVC;
@property (nonatomic, weak) UIButton *lastSelectedButton;
@property (nonatomic, strong) SJStockTimeLineViewController *timeLineVC;

@end

@implementation SJStockHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineHeightConstraint.constant = 0.5f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    SJStockTimeLineViewController *timeLineVC = [[SJStockTimeLineViewController alloc] init];
    timeLineVC.stock_code = self.stock_code;
    timeLineVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:timeLineVC.view];
    self.lastSelectedVC = timeLineVC;
    self.lastSelectedButton = self.timeButton;
}

- (void)setDataArray:(NSArray *)dataArray {
    if (_dataArray != dataArray) {
        _dataArray = dataArray;
    }

    self.currentPriceLabel.text = [NSString stringWithFormat:@"%@", [_dataArray objectAtIndex:3]];
    self.openLabel.text = [NSString stringWithFormat:@"%@", [_dataArray objectAtIndex:5]];
    self.yesterdayCloseLabel.text = [NSString stringWithFormat:@"%@", [_dataArray objectAtIndex:4]];
    self.volLabel.text = [NSString stringWithFormat:@"%@", [self changeValue:[[_dataArray objectAtIndex:6] floatValue]]];
    self.exchangeLabel.text = [NSString stringWithFormat:@"%@%@", [_dataArray objectAtIndex:38], @"%"];
    self.higheLabel.text = [NSString stringWithFormat:@"%@", [_dataArray objectAtIndex:33]];
    self.lowLabel.text = [NSString stringWithFormat:@"%@", [_dataArray objectAtIndex:34]];
    self.tradeCountLabel.text = [self changeAmount:[[_dataArray objectAtIndex:37] floatValue]];
    self.neipanLabel.text = [NSString stringWithFormat:@"%@", [self changeValue:[[_dataArray objectAtIndex:8] floatValue]]];
    self.waipanLabel.text = [NSString stringWithFormat:@"%@", [self changeValue:[[_dataArray objectAtIndex:7] floatValue]]];
    self.shizhiLabel.text = [NSString stringWithFormat:@"%@亿",[_dataArray objectAtIndex:45]];
    self.shiyinglvLabel.text = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:39]];
    self.zhenfuLabel.text = [NSString stringWithFormat:@"%@%@",[_dataArray objectAtIndex:43], @"%"];
    self.liutongshizhiLabel.text = [NSString stringWithFormat:@"%@亿",[_dataArray objectAtIndex:44]];
    
    NSString *zhangdieString =[NSString stringWithFormat: @"%@",[_dataArray objectAtIndex:31]];
    CGFloat zhangdieFloat = [zhangdieString floatValue];
    if (zhangdieFloat > 0.00 || zhangdieFloat == 0) {
        self.currentPriceLabel.textColor = RGB(217, 67, 50);
        self.zhangdieLabel.textColor = RGB(217, 67, 50);
        self.zhangdiefuLabel.textColor = RGB(217, 67, 50);
        self.openLabel.textColor = RGB(217, 67, 50);
        self.higheLabel.textColor = RGB(217, 67, 50);
        self.lowLabel.textColor = RGB(217, 67, 50);
        self.zhangdieLabel.text = [NSString stringWithFormat:@"+%@", [_dataArray objectAtIndex:31]];
        self.zhangdiefuLabel.text = [NSString stringWithFormat:@"+%@%@", [_dataArray objectAtIndex:32], @"%"];
    } else {
        self.currentPriceLabel.textColor =RGB(34, 172, 56);
        self.zhangdieLabel.textColor = RGB(34, 172, 56);
        self.zhangdiefuLabel.textColor = RGB(34, 172, 56);
        self.openLabel.textColor = RGB(34, 172, 56);
        self.higheLabel.textColor = RGB(34, 172, 56);
        self.lowLabel.textColor = RGB(34, 172, 56);
        self.zhangdieLabel.text = [NSString stringWithFormat:@"%@", [_dataArray objectAtIndex:31]];
        self.zhangdiefuLabel.text = [NSString stringWithFormat:@"%@%@", [_dataArray objectAtIndex:32], @"%"];
    }
}

- (NSString *)changeValue:(CGFloat)value {
    CGFloat newPrice = value;
    NSString *danwei = @"手";
    if ((int)value > 10000) {
        newPrice = value / 10000 ;
        danwei = @"万手";
    } else if ((int)value > 10000000) {
        newPrice = value / 10000000 ;
        danwei = @"千万手";
    } else if ((int)value > 100000000) {
        newPrice = value / 100000000 ;
        danwei = @"亿手";
    }
    NSString *newstr = [[NSString alloc] initWithFormat:@"%.2f%@",newPrice,danwei];
    return newstr;
}

- (NSString *)changeAmount:(CGFloat)amount {
    CGFloat newPrice = amount;
    NSString *danwei = @"万";
    if ((int)amount > 10000) {
        newPrice = amount / 10000 ;
        danwei = @"亿";
    }
    NSString *newstr = [[NSString alloc] initWithFormat:@"%.2f%@",newPrice,danwei];
    return newstr;
}

- (IBAction)timeButton:(id)sender {
    if ([self.lastSelectedButton isEqual:self.timeButton]) {
        return;
    }
    SJStockTimeLineViewController *timeLineVC = [[SJStockTimeLineViewController alloc] init];
    timeLineVC.stock_code = self.stock_code;
    timeLineVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:timeLineVC.view];
    [self.lastSelectedVC.view removeFromSuperview];
    self.lastSelectedVC = timeLineVC;
    self.timeButton.selected = YES;
    self.lastSelectedButton.selected = NO;
    self.lastSelectedButton = self.timeButton;
}

- (IBAction)dayButton:(id)sender {
    if ([self.lastSelectedButton isEqual:self.dayButton]) {
        return;
    }
    SJStockDayLineViewController *dayLineVC = [[SJStockDayLineViewController alloc] init];
    dayLineVC.stock_code = self.stock_code;
    dayLineVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:dayLineVC.view];
    [self.contentView sendSubviewToBack:dayLineVC.view];
    [self.lastSelectedVC.view removeFromSuperview];
    self.lastSelectedVC = dayLineVC;
    self.dayButton.selected = YES;
    self.lastSelectedButton.selected = NO;
    self.lastSelectedButton = self.dayButton;
}

- (IBAction)weekButton:(id)sender {
    if ([self.lastSelectedButton isEqual:self.weekButton]) {
        return;
    }
    SJStockWeekLineViewController *weekLineVC = [[SJStockWeekLineViewController alloc] init];
    weekLineVC.stock_code = self.stock_code;
    weekLineVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:weekLineVC.view];
    [self.contentView sendSubviewToBack:weekLineVC.view];
    [self.lastSelectedVC.view removeFromSuperview];
    self.lastSelectedVC = weekLineVC;
    self.weekButton.selected = YES;
    self.lastSelectedButton.selected = NO;
    self.lastSelectedButton = self.weekButton;
}

- (IBAction)monthButton:(id)sender {
    if ([self.lastSelectedButton isEqual:self.monthButton]) {
        return;
    }
    SJStockMonthLineViewController *monthLineVC = [[SJStockMonthLineViewController alloc] init];
    monthLineVC.stock_code = self.stock_code;
    monthLineVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:monthLineVC.view];
    [self.contentView sendSubviewToBack:monthLineVC.view];
    [self.lastSelectedVC.view removeFromSuperview];
    self.lastSelectedVC = monthLineVC;
    self.monthButton.selected = YES;
    self.lastSelectedButton.selected = NO;
    self.lastSelectedButton = self.monthButton;
}

@end

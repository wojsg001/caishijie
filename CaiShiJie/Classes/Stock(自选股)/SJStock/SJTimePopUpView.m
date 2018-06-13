//
//  SJTimePopUpView.m
//  QuartzDemo
//
//  Created by user on 16/9/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJTimePopUpView.h"
#import "UIColor+helper.h"

@interface SJTimePopUpView ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *netChangeRatioLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *volLabel;

@end

@implementation SJTimePopUpView

- (void)setDic:(NSDictionary *)dic {
    if (_dic != dic) {
        _dic = dic;
    }
    
    NSInteger time = [dic[@"time"] integerValue]/100000;
    if (time/100 < 10) {
        self.timeLabel.text = [NSString stringWithFormat:@"0%d:%d", time/100, time%100];
    } else if (time%100 < 10) {
        self.timeLabel.text = [NSString stringWithFormat:@"%d:0%d", time/100, time%100];
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%d:%d", time/100, time%100];
    }
    self.currentPriceLabel.text = [NSString stringWithFormat:@"%.2f", [dic[@"price"] floatValue]];
    self.netChangeRatioLabel.text = [NSString stringWithFormat:@"%.2f%@", [dic[@"netChangeRatio"] floatValue], @"%"];
    self.avgPriceLabel.text = [NSString stringWithFormat:@"%.2f", [dic[@"avgPrice"] floatValue]];
    self.volLabel.text = [NSString stringWithFormat:@"%d手", [dic[@"volume"] integerValue] / 100];
    if ([dic[@"netChangeRatio"] floatValue] > 0.0) {
        self.currentPriceLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
        self.netChangeRatioLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
        self.avgPriceLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([dic[@"netChangeRatio"] floatValue] < 0.0) {
        self.currentPriceLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
        self.netChangeRatioLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
        self.avgPriceLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.currentPriceLabel.textColor = [UIColor colorWithHexString:@"#000000" withAlpha:1];
        self.netChangeRatioLabel.textColor = [UIColor colorWithHexString:@"#000000" withAlpha:1];
        self.avgPriceLabel.textColor = [UIColor colorWithHexString:@"#000000" withAlpha:1];
    }
}

@end

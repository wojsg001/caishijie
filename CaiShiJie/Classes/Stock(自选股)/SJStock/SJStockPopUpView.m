//
//  SJStockPopUpView.m
//  QuartzDemo
//
//  Created by user on 18/9/20.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJStockPopUpView.h"
#import "UIColor+helper.h"

@interface SJStockPopUpView ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;
@property (weak, nonatomic) IBOutlet UILabel *upsAndDownsLabel;
@property (weak, nonatomic) IBOutlet UILabel *volLabel;

@end

@implementation SJStockPopUpView

- (void)setItem:(NSArray *)item {
    if (_item != item) {
        _item = item;
    }
    self.dateLabel.text = [item objectAtIndex:9];
    self.openLabel.text = [NSString stringWithFormat:@"%.2f", [[item objectAtIndex:0] floatValue]];
    self.highLabel.text = [NSString stringWithFormat:@"%.2f", [[item objectAtIndex:1] floatValue]];
    self.lowLabel.text = [NSString stringWithFormat:@"%.2f", [[item objectAtIndex:2] floatValue]];
    self.closeLabel.text = [NSString stringWithFormat:@"%.2f", [[item objectAtIndex:3] floatValue]];
    self.upsAndDownsLabel.text = [NSString stringWithFormat:@"%.2f%@", [[item objectAtIndex:8] floatValue], @"%"];
    self.volLabel.text = [self changePrice:[[item objectAtIndex:4] floatValue]/100];
    
    if ([[item objectAtIndex:8] floatValue] < 0) {
        self.openLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
        self.highLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
        self.lowLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
        self.closeLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
        self.upsAndDownsLabel.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:self.alpha];
    } else {
        self.openLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha];
        self.highLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha];
        self.lowLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha];
        self.closeLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha];
        self.upsAndDownsLabel.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:self.alpha];
    }
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

@end

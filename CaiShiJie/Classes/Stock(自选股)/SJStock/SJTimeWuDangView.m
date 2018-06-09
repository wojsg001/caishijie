//
//  SJTimeWuDangView.m
//  QuartzDemo
//
//  Created by user on 16/9/26.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTimeWuDangView.h"
#import "UIColor+helper.h"

@interface SJTimeWuDangView ()

@property (weak, nonatomic) IBOutlet UILabel *sell5Price;
@property (weak, nonatomic) IBOutlet UILabel *sell4Price;
@property (weak, nonatomic) IBOutlet UILabel *sell3Price;
@property (weak, nonatomic) IBOutlet UILabel *sell2Price;
@property (weak, nonatomic) IBOutlet UILabel *sell1Price;
@property (weak, nonatomic) IBOutlet UILabel *sell5Count;
@property (weak, nonatomic) IBOutlet UILabel *sell4Count;
@property (weak, nonatomic) IBOutlet UILabel *sell3Count;
@property (weak, nonatomic) IBOutlet UILabel *sell2Count;
@property (weak, nonatomic) IBOutlet UILabel *sell1Count;
@property (weak, nonatomic) IBOutlet UILabel *buy1Price;
@property (weak, nonatomic) IBOutlet UILabel *buy2Price;
@property (weak, nonatomic) IBOutlet UILabel *buy3Price;
@property (weak, nonatomic) IBOutlet UILabel *buy4Price;
@property (weak, nonatomic) IBOutlet UILabel *buy5Price;
@property (weak, nonatomic) IBOutlet UILabel *buy1Count;
@property (weak, nonatomic) IBOutlet UILabel *buy2Count;
@property (weak, nonatomic) IBOutlet UILabel *buy3Count;
@property (weak, nonatomic) IBOutlet UILabel *buy4Count;
@property (weak, nonatomic) IBOutlet UILabel *buy5Count;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;

@end

@implementation SJTimeWuDangView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineHeightConstraint.constant = 0.5f;
}

- (void)setSellArray:(NSArray *)sellArray {
    if (_sellArray != sellArray) {
        _sellArray = sellArray;
    }
    
    NSDictionary *tmpDic1 = _sellArray[0];
    if ([tmpDic1[@"price"] floatValue] == 0.00) {
        self.sell1Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic1[@"price"] floatValue] > [self.preClose floatValue]) {
        self.sell1Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic1[@"price"] floatValue] < [self.preClose floatValue]) {
        self.sell1Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.sell1Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.sell1Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic1[@"price"] floatValue]];
    self.sell1Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic1[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic2 = _sellArray[1];
    if ([tmpDic2[@"price"] floatValue] == 0.00) {
        self.sell2Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic2[@"price"] floatValue] > [self.preClose floatValue]) {
        self.sell2Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic2[@"price"] floatValue] < [self.preClose floatValue]) {
        self.sell2Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.sell2Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.sell2Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic2[@"price"] floatValue]];
    self.sell2Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic2[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic3 = _sellArray[2];
    if ([tmpDic3[@"price"] floatValue] == 0.00) {
        self.sell3Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic3[@"price"] floatValue] > [self.preClose floatValue]) {
        self.sell3Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic3[@"price"] floatValue] < [self.preClose floatValue]) {
        self.sell3Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.sell3Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.sell3Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic3[@"price"] floatValue]];
    self.sell3Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic3[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic4 = _sellArray[3];
    if ([tmpDic4[@"price"] floatValue] == 0.00) {
        self.sell4Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic4[@"price"] floatValue] > [self.preClose floatValue]) {
        self.sell4Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic4[@"price"] floatValue] < [self.preClose floatValue]) {
        self.sell4Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.sell4Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.sell4Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic4[@"price"] floatValue]];
    self.sell4Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic4[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic5 = _sellArray[4];
    if ([tmpDic5[@"price"] floatValue] == 0.00) {
        self.sell5Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic5[@"price"] floatValue] > [self.preClose floatValue]) {
        self.sell5Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic5[@"price"] floatValue] < [self.preClose floatValue]) {
        self.sell5Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.sell5Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.sell5Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic5[@"price"] floatValue]];
    self.sell5Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic5[@"volume"] integerValue] / 100];
}

- (void)setBuyArray:(NSArray *)buyArray {
    if (_buyArray != buyArray) {
        _buyArray = buyArray;
    }
    
    NSDictionary *tmpDic1 = _buyArray[0];
    if ([tmpDic1[@"price"] floatValue] == 0.00) {
        self.buy1Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic1[@"price"] floatValue] > [self.preClose floatValue]) {
        self.buy1Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic1[@"price"] floatValue] < [self.preClose floatValue]) {
        self.buy1Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.buy1Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.buy1Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic1[@"price"] floatValue]];
    self.buy1Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic1[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic2 = _buyArray[1];
    if ([tmpDic2[@"price"] floatValue] == 0.00) {
        self.buy2Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic2[@"price"] floatValue] > [self.preClose floatValue]) {
        self.buy2Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic2[@"price"] floatValue] < [self.preClose floatValue]) {
        self.buy2Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.buy2Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.buy2Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic2[@"price"] floatValue]];
    self.buy2Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic2[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic3 = _buyArray[2];
    if ([tmpDic3[@"price"] floatValue] == 0.00) {
        self.buy3Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic3[@"price"] floatValue] > [self.preClose floatValue]) {
        self.buy3Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic3[@"price"] floatValue] < [self.preClose floatValue]) {
        self.buy3Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.buy3Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.buy3Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic3[@"price"] floatValue]];
    self.buy3Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic3[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic4 = _buyArray[3];
    if ([tmpDic4[@"price"] floatValue] == 0.00) {
        self.buy4Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic4[@"price"] floatValue] > [self.preClose floatValue]) {
        self.buy4Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic4[@"price"] floatValue] < [self.preClose floatValue]) {
        self.buy4Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.buy4Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.buy4Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic4[@"price"] floatValue]];
    self.buy4Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic4[@"volume"] integerValue] / 100];
    
    NSDictionary *tmpDic5 = _buyArray[4];
    if ([tmpDic5[@"price"] floatValue] == 0.00) {
        self.buy5Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    } else if ([tmpDic5[@"price"] floatValue] > [self.preClose floatValue]) {
        self.buy5Price.textColor = [UIColor colorWithHexString:@"#D94332" withAlpha:1];
    } else if ([tmpDic5[@"price"] floatValue] < [self.preClose floatValue]) {
        self.buy5Price.textColor = [UIColor colorWithHexString:@"#22AC38" withAlpha:1];
    } else {
        self.buy5Price.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
    }
    self.buy5Price.text = [NSString stringWithFormat:@"%.2f", [tmpDic5[@"price"] floatValue]];
    self.buy5Count.text = [NSString stringWithFormat:@"%ld", (long)[tmpDic5[@"volume"] integerValue] / 100];
}

@end

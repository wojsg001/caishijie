//
//  SJRecommendStockCell.m
//  CaiShiJie
//
//  Created by user on 18/5/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRecommendStockCell.h"
#import "SJRecommendStockModel.h"

@interface SJRecommendStockCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *increaseLabel;

@end

@implementation SJRecommendStockCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(SJRecommendStockModel *)model {
    _model = model;
    
    self.nameLabel.text = _model.name;
    self.codeLabel.text = _model.code2;
    self.currentPriceLabel.text = _model.currentPrice;
    self.increaseLabel.text = _model.zhangdie;
    
    if ([_model.zhangdie doubleValue] > 0.00) {
        self.increaseLabel.textColor = RGB(217, 67, 50);
    } else if ([_model.zhangdie doubleValue] < 0.00) {
        self.increaseLabel.textColor = RGB(34, 172, 56);
    } else {
        self.increaseLabel.textColor = RGB(64, 64, 64);
    }
}

@end

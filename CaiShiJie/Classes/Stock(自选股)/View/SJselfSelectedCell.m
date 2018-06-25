//
//  SJselfSelectedCell.m
//  CaiShiJie
//
//  Created by user on 18/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJselfSelectedCell.h"

@interface SJselfSelectedCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *banckview;
@property (weak, nonatomic) IBOutlet UILabel *roselable;

@end

@implementation SJselfSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.banckview.layer.cornerRadius =2;
    self.banckview.layer.masksToBounds =YES;
    self.roselable.textAlignment =NSTextAlignmentCenter;
    self.selectionStyle =UITableViewCellSelectionStyleNone;
}

- (void)setDict:(NSDictionary *)dict {
    _dict = dict;
    
    self.nameLabel.text = _dict[@"name"];
    self.codeLabel.text = [NSString stringWithFormat:@"%@", _dict[@"code"]];
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f", [_dict[@"trade"] floatValue]];
    
    if ([self.priceLabel.text isEqualToString:@"0.00"]) {
        self.roselable.text = @"----";
        self.roselable.textColor = RGB(0, 0, 0);
        self.banckview.backgroundColor = RGB(255, 255, 255);
    } else {
        float increase = [_dict[@"changepercent"] floatValue];
        if (increase > 0.00) {
            NSString *tmpStr = [NSString stringWithFormat:@"+%.2f", increase];
            self.roselable.text = [tmpStr stringByAppendingString:@"%"];
            self.roselable.textColor = RGB(255, 255, 255);
            self.banckview.backgroundColor = RGB(217, 67, 50);
        } else if (increase < 0.00) {
            NSString *tmpStr = [NSString stringWithFormat:@"%.2f", increase];
            self.roselable.text = [tmpStr stringByAppendingString:@"%"];
            self.roselable.textColor = RGB(255, 255, 255);
            self.banckview.backgroundColor = RGB(34, 172, 56);
        } else {
            self.roselable.text = @"----";
            self.roselable.textColor = RGB(0, 0, 0);
            self.banckview.backgroundColor = RGB(255, 255, 255);
        }
    }
}

@end

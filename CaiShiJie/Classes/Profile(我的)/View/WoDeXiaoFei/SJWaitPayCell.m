//
//  SJWaitPayCell.m
//  CaiShiJie
//
//  Created by user on 18/3/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJWaitPayCell.h"
#import "SJBillModel.h"

@interface SJWaitPayCell ()

@property (weak, nonatomic) IBOutlet UILabel *item_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation SJWaitPayCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setBillModel:(SJBillModel *)billModel
{
    _billModel = billModel;
    
    NSString *item_type;
    if ([_billModel.item_type isEqualToString:@"1"])
    {
        item_type = @"礼物";
    }
    else if ([_billModel.item_type isEqualToString:@"2"])
    {
        item_type = @"红包";
    }
    else if ([_billModel.item_type isEqualToString:@"3"])
    {
        item_type = @"上香";
    }
    else if ([_billModel.item_type isEqualToString:@"20"])
    {
        item_type = @"投资内参";
    }
    
    NSString *item_name = _billModel.item_name;
    if (item_name == nil) {
        item_name = @"----";
    }
    self.item_nameLabel.text = [NSString stringWithFormat:@"%@ “%@”",item_type,item_name];
    self.timeLabel.text = _billModel.created_at;
    self.priceLabel.text = _billModel.price;
    
    NSString *status;
    if ([_billModel.status isEqualToString:@"30"])
    {
        status = @"已完成";
    }
    else if ([_billModel.status isEqualToString:@"1"])
    {
        status = @"已过期";
    }
    else if ([_billModel.status isEqualToString:@"10"])
    {
        status = @"失败";
    }
    else if ([_billModel.status isEqualToString:@"20"])
    {
        status = @"待支付";
    }
    
    self.statusLabel.text = status;
}

@end

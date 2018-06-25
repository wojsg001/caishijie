//
//  SJGivePresentCell.m
//  CaiShiJie
//
//  Created by user on 18/11/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGivePresentCell.h"
#import "SJGiftModel.h"

@interface SJGivePresentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation SJGivePresentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setGiftModel:(SJGiftModel *)giftModel {
    _giftModel = giftModel;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://common.csjimg.com/gift/%@",_giftModel.img]] placeholderImage:[UIImage imageNamed:@"live_gift_img_n"]];
    self.nameLabel.text = _giftModel.gift_name;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@金币",_giftModel.price];
}

@end

//
//  SJFullVideoGiftCell.m
//  CaiShiJie
//
//  Created by user on 16/8/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJFullVideoGiftCell.h"
#import "SJGiftModel.h"

@interface SJFullVideoGiftCell ()

@property (weak, nonatomic) IBOutlet UIImageView *giftIcon;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectIcon;

@end

@implementation SJFullVideoGiftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelectIconHidden:(BOOL)hidden {
    self.selectIcon.hidden = hidden;
}

- (void)setModel:(SJGiftModel *)model {
    _model = model;
    
    [_giftIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://common.csjimg.com/gift/%@",_model.img]] placeholderImage:[UIImage imageNamed:@"live_gift_img_n"]];
    _giftNameLabel.text = _model.gift_name;
    _giftPriceLabel.text = [NSString stringWithFormat:@"%@金币", _model.price];
}

@end

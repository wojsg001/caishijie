//
//  SJPresentCell.m
//  CaiShiJie
//
//  Created by user on 16/1/12.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPresentCell.h"
#import "SJGiftModel.h"
#import "UIImageView+WebCache.h"

@interface SJPresentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation SJPresentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setGiftModel:(SJGiftModel *)giftModel
{
    _giftModel = giftModel;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://common.csjimg.com/gift/%@",_giftModel.img]] placeholderImage:[UIImage imageNamed:@"live_gift_img_n"]];
    self.nameLabel.text = _giftModel.gift_name;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@金币",_giftModel.price];
    
}

@end

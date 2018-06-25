//
//  SJHisReferenceCell.m
//  CaiShiJie
//
//  Created by user on 18/3/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHisReferenceCell.h"
#import "SJMyNeiCan.h"
#import "UIImageView+WebCache.h"

@interface SJHisReferenceCell ()

@property (weak, nonatomic) IBOutlet UIImageView *reference_imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pay_countLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@end

@implementation SJHisReferenceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setHisReference:(SJMyNeiCan *)hisReference
{
    _hisReference = hisReference;
    
    [_reference_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_hisReference.reference_img]] placeholderImage:[UIImage imageNamed:@"neican_photo"]];
    _titleLabel.text = _hisReference.title;
    _serviceDateLabel.text = [NSString stringWithFormat:@"服务期：%@至%@",_hisReference.start_at,_hisReference.end_at];
    _summaryLabel.text = _hisReference.summary;
    _priceLabel.text = [NSString stringWithFormat:@"¥%@",_hisReference.price];
    _pay_countLabel.text = [NSString stringWithFormat:@"%@人订阅",_hisReference.pay_count];
    
    
    if ([_hisReference.status isEqualToString:@"0"]) {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon2"] forState:UIControlStateNormal];
        if ([_hisReference.isPay isEqualToString:@"0"]) {
            [_payBtn setImage:[UIImage imageNamed:@"neican_btn2"] forState:UIControlStateNormal];
        } else {
            [_payBtn setImage:[UIImage imageNamed:@"neican_btn1"] forState:UIControlStateNormal];
        }
    } else if ([_hisReference.status isEqualToString:@"1"]) {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon3"] forState:UIControlStateNormal];
        [_payBtn setImage:[UIImage imageNamed:@"neican_btn_end"] forState:UIControlStateNormal];
    } else if ([_hisReference.status isEqualToString:@"2"]) {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon1"] forState:UIControlStateNormal];
        [_payBtn setImage:[UIImage imageNamed:@"neican_btn_end"] forState:UIControlStateNormal];
    }
}

#pragma mark - 点击了购买按钮
- (IBAction)ClickPayButton:(id)sender
{
    if ([_hisReference.status isEqualToString:@"0"] && ![_hisReference.isPay isEqualToString:@"0"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPayButtonWith:)]) {
            [self.delegate didClickPayButtonWith:_hisReference];
        }
    }
}

@end

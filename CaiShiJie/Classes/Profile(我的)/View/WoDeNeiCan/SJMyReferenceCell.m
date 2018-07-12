//
//  SJMyReferenceCell.m
//  CaiShiJie
//
//  Created by user on 18/3/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyReferenceCell.h"
#import "SJMyNeiCan.h"
#import "UIImageView+WebCache.h"

@interface SJMyReferenceCell ()

@property (weak, nonatomic) IBOutlet UIImageView *reference_imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pay_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *created_atLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pay_countLabelWidthMargin;


@end

@implementation SJMyReferenceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTeacherReference:(SJMyNeiCan *)teacherReference
{
    _teacherReference = teacherReference;
    
//    [_reference_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_teacherReference.reference_img]] placeholderImage:[UIImage imageNamed:@"neican_photo"]];
    
    [_reference_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_teacherReference.reference_img]] placeholderImage:[UIImage imageNamed:@"AppIcon"]];
    
    _titleLabel.text = _teacherReference.title;
    _serviceDateLabel.text = [NSString stringWithFormat:@"服务期：%@至%@",_teacherReference.start_at,_teacherReference.end_at];
    _summaryLabel.text = _teacherReference.summary;
    _priceLabel.text = [NSString stringWithFormat:@"¥%@",_teacherReference.price];
    [_priceLabel setHidden:YES];
    _pay_countLabel.text = [NSString stringWithFormat:@"%@人订阅",_teacherReference.pay_count];
    [_pay_countLabel sizeToFit];
    [_pay_countLabel setHidden:YES];
    // 修改订阅人数label的宽度约束
    _pay_countLabelWidthMargin.constant = _pay_countLabel.width;
    
    _created_atLabel.text = [NSString stringWithFormat:@"发布时间：%@",_teacherReference.created_at];
    
    if ([_teacherReference.status isEqualToString:@"0"])
    {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon2"] forState:UIControlStateNormal];
    }
    else if ([_teacherReference.status isEqualToString:@"1"])
    {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon3"] forState:UIControlStateNormal];
    }
    else if ([_teacherReference.status isEqualToString:@"2"])
    {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon1"] forState:UIControlStateNormal];
    }
    [_statusBtn setHidden:YES];
}

- (void)setUserReference:(SJMyNeiCan *)userReference
{
    _userReference = userReference;
    
//    [_reference_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_userReference.reference_img]] placeholderImage:[UIImage imageNamed:@"neican_photo"]];
    
    [_reference_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_teacherReference.reference_img]] placeholderImage:[UIImage imageNamed:@"AppIcon"]];
    
    _titleLabel.text = _userReference.title;
    _serviceDateLabel.text = [NSString stringWithFormat:@"服务期：%@至%@",_userReference.start_at,_userReference.end_at];
    _summaryLabel.text = _userReference.summary;
    _priceLabel.text = [NSString stringWithFormat:@"¥%@",_userReference.price];
    [_priceLabel setHidden:YES];
    _pay_countLabel.text = [NSString stringWithFormat:@"%@人订阅",_userReference.pay_count];
    [_pay_countLabel sizeToFit];
    [_pay_countLabel setHidden:YES];
    
    // 修改订阅人数label的宽度约束
    _pay_countLabelWidthMargin.constant = _pay_countLabel.width;
    
    _created_atLabel.text = [NSString stringWithFormat:@"购买时间：%@",_userReference.pay_created_at];
    
    if ([_userReference.status isEqualToString:@"0"])
    {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon2"] forState:UIControlStateNormal];
    }
    else if ([_userReference.status isEqualToString:@"1"])
    {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon3"] forState:UIControlStateNormal];
    }
    else if ([_userReference.status isEqualToString:@"2"])
    {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon1"] forState:UIControlStateNormal];
    }
    [_statusBtn setHidden:YES];
}

@end

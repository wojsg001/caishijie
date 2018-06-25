//
//  SJZhuanLanTwoCell.m
//  CaiShiJie
//
//  Created by user on 18/5/27.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJZhuanLanTwoCell.h"
#import "SJBlogZhuanLanModel.h"

@interface SJZhuanLanTwoCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *headIcon_byView;
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;

@end

@implementation SJZhuanLanTwoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.contentView layoutIfNeeded];
    self.bgView.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.bgView.layer.borderWidth = 0.5f;
    self.headIcon_byView.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.headIcon_byView.layer.borderWidth = 1.0f;
    self.headIcon_byView.layer.cornerRadius = self.headIcon_byView.height/2;
    self.headIcon_byView.layer.masksToBounds = YES;
    self.headIcon.layer.cornerRadius = self.headIcon.height/2;
    self.headIcon.layer.masksToBounds = YES;
}

- (void)setModel:(SJBlogZhuanLanModel *)model
{
    _model = model;
    
    [self.headIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"photo_n_525px"]];
    self.nickNameLabel.text = _model.nickname;
    self.introductionLabel.text = _model.introduce;
}

@end

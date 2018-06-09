//
//  SJIntoTeacherCell.m
//  CaiShiJie
//
//  Created by user on 16/5/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJIntoTeacherCell.h"
#import "SJCustom.h"
#import "UIImageView+WebCache.h"

@interface SJIntoTeacherCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *honorLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillLabel;

@end

@implementation SJIntoTeacherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lineViewHeight.constant = 0.5f;
}

- (void)setModel:(SJCustom *)model
{
    _model = model;
    
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"index_account_photo2"]];
    self.nickNameLabel.text = _model.nickname;
    self.honorLabel.text = _model.honor;
    self.skillLabel.text = _model.label;
}

@end

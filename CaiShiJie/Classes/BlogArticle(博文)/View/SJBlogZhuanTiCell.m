//
//  SJBlogZhuanTiCell.m
//  CaiShiJie
//
//  Created by user on 18/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogZhuanTiCell.h"
#import "SJBlogZhuanTiModel.h"

@interface SJBlogZhuanTiCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SJBlogZhuanTiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.topLineHeight.constant = 0.5f;
    self.bottomLineHeight.constant = 0.5f;
}

- (void)setModel:(SJBlogZhuanTiModel *)model
{
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.img]] placeholderImage:[UIImage imageNamed:@"article_zhuanti_n"]];
    self.titleLabel.text = _model.title;
}

@end

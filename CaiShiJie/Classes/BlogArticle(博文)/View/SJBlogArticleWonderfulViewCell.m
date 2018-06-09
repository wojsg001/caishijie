//
//  SJBlogArticleWonderfulViewCell.m
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBlogArticleWonderfulViewCell.h"
#import "SJBlogZhuanTiModel.h"

@interface SJBlogArticleWonderfulViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@end

@implementation SJBlogArticleWonderfulViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.bgImgView.layer.cornerRadius = 4.0f;
    self.bgImgView.layer.masksToBounds = YES;
}

- (void)setModel:(SJBlogZhuanTiModel *)model
{
    _model = model;
    
    [_bgImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.img]] placeholderImage:[UIImage imageNamed:@"article_zhuanti_n"]];
}

@end

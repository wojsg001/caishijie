//
//  SJRecommendBlogArticleCell.m
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRecommendBlogArticleCell.h"
#import "SJBlogArticleModel.h"

@interface SJRecommendBlogArticleCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *praiseLabel;

@end

@implementation SJRecommendBlogArticleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lineViewHeight.constant = 0.5f;
    
    self.headImgView.layer.cornerRadius = 4.0f;
    self.headImgView.layer.masksToBounds = YES;
}

- (void)setModel:(SJBlogArticleModel *)model
{
    _model = model;
    
    self.titleLabel.text = _model.title;
    self.summaryLabel.text = _model.summary;
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"article_pto_n"]];
    self.nicknameLabel.text = _model.nickname;
    self.timeLabel.text = _model.created_at;
    self.praiseLabel.text = _model.praise;
}

@end

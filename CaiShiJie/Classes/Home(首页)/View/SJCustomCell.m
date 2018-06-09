//
//  SJCustomCell.m
//  testDemo
//
//  Created by user on 15/12/23.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJCustomCell.h"

#import "UIImageView+WebCache.h"
#import "SJCustom.h"

@interface SJCustomCell ()

@property (weak, nonatomic) IBOutlet UIImageView *head_imgView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *honorLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UILabel *question_countLabel;

@end

@implementation SJCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.zhixunBtn.layer.borderColor = RGB(217, 67, 50).CGColor;
    self.zhixunBtn.layer.borderWidth = 1.0f;
    self.zhixunBtn.layer.cornerRadius = 3.0;
    self.zhixunBtn.layer.masksToBounds = YES;
    
    self.view.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.view.layer.borderWidth = 0.5f;
    self.view.layer.cornerRadius = 5.0;
    self.view.layer.masksToBounds = YES;
}

- (void)setRecommendMaster:(SJCustom *)recommendMaster {
    _recommendMaster = recommendMaster;
    
    [self.head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_recommendMaster.head_img]] placeholderImage:[UIImage imageNamed:@"attention_photo2"]];
    self.nicknameLabel.text = _recommendMaster.nickname;
    self.honorLabel.text = _recommendMaster.honor;
    self.label.text = _recommendMaster.label;
    self.likeLabel.text = _recommendMaster.like;
    self.fansLabel.text = _recommendMaster.fans;
    self.question_countLabel.text = _recommendMaster.question_count;
}

@end

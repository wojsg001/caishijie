//
//  SJBlogRankCell.m
//  CaiShiJie
//
//  Created by user on 16/5/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBlogRankCell.h"
#import "SJBlogRankModel.h"

@interface SJBlogRankCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *clickCountLabel;

@end

@implementation SJBlogRankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bottomLineHeight.constant = 0.5f;
}

- (void)setModel:(SJBlogRankModel *)model
{
    _model = model;
    
    self.titleLabel.text = _model.title;
    self.clickCountLabel.text = _model.clicks;
}

@end

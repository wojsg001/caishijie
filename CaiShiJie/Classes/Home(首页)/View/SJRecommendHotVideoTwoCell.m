//
//  SJRecommendHotVideoTwoCell.m
//  CaiShiJie
//
//  Created by user on 16/5/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRecommendHotVideoTwoCell.h"
#import "SJRecommendVideoModel.h"

@interface SJRecommendHotVideoTwoCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end

@implementation SJRecommendHotVideoTwoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(SJRecommendVideoModel *)model {
    _model = model;
    
    _titleLabel.text = _model.title;
    _summaryLabel.text = _model.summary;
    _nickNameLabel.text = _model.nickname;
}



@end

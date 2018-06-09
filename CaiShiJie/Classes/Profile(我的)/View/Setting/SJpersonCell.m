//
//  SJpersonCell.m
//  CaiShiJie
//
//  Created by user on 16/4/11.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJpersonCell.h"

@implementation SJpersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headimage.layer.cornerRadius =4;
    self.headimage.layer.masksToBounds =YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

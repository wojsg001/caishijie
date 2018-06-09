//
//  SJLiveOpenMessageCell.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJLiveOpenMessageCell.h"

@interface SJLiveOpenMessageCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SJLiveOpenMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

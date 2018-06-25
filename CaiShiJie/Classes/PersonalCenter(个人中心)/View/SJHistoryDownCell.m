//
//  SJHistoryDownCell.m
//  CaiShiJie
//
//  Created by user on 18/1/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHistoryDownCell.h"
#import "SJOldModel.h"

@interface SJHistoryDownCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;

@end

@implementation SJHistoryDownCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineHeightConstraint.constant = 0.5f;
}

- (void)setOldLiveModel:(SJOldModel *)oldLiveModel
{
    _oldLiveModel = oldLiveModel;
    
    self.titleL.text = _oldLiveModel.title;
    self.timeLabel.text = _oldLiveModel.created_at;
}

@end

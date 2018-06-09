//
//  SJCSJMessageCell.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJCSJMessageCell.h"
#import "SJCSJMessageModel.h"

@interface SJCSJMessageCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SJCSJMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleBackgroundView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.titleBackgroundView.layer.borderWidth = 0.5f;
}

- (void)setModel:(SJCSJMessageModel *)model {
    _model = model;
    
    self.timeLabel.text = _model.created_at;
    self.titleLabel.text = _model.content;
}

@end

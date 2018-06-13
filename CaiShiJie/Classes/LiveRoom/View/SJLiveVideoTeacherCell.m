//
//  SJLiveVideoTeacherCell.m
//  CaiShiJie
//
//  Created by user on 16/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveVideoTeacherCell.h"
#import "SJNewLiveVideoTeacherModel.h"

@interface SJLiveVideoTeacherCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end

@implementation SJLiveVideoTeacherCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.headIcon.layer.cornerRadius = 10;
    self.headIcon.layer.masksToBounds = YES;
    self.headIcon.layer.borderWidth = 0.5f;
    self.headIcon.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
}

- (void)setModel:(SJNewLiveVideoTeacherModel *)model {
    if (_model != model) {
        _model = model;
    }
    
    [_headIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"photo_n_300px"]];
    _nameLabel.text = _model.nickname;
    if (_model.introduction == nil) {
        _summaryLabel.text = @"暂无";
    } else {
        _summaryLabel.text = _model.introduction;
    }
}

@end

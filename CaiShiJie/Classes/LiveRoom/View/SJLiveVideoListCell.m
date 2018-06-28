//
//  SJLiveVideoListCell.m
//  CaiShiJie
//
//  Created by user on 18/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveVideoListCell.h"
#import "SJNewLiewVideoListModel.h"

@interface SJLiveVideoListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation SJLiveVideoListCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setModel:(SJNewLiewVideoListModel *)model {
    if (_model != model) {
        _model = model;
    }
    _titleLabel.text = [NSString stringWithFormat:@"财富密码%@", _model.title];
    _timeLabel.text = [NSString stringWithFormat:@"时间: %@-%@(工作日)", _model.start_at, _model.end_at];
    _authorLabel.text = [NSString stringWithFormat:@"主持: %@", _model.presenter];
    if ([_model.status isEqualToString:@"formerly"]) {
        _statusIcon.image = [UIImage imageNamed:@"new_todaylive_icon3"];
        _statusLabel.text = @"回放";
        _statusLabel.textColor = [UIColor whiteColor];
    } else if ([_model.status isEqualToString:@"will"]) {
        _statusIcon.image = [UIImage imageNamed:@"new_todaylive_icon5"];
        _statusLabel.text = @"未开始";
        _statusLabel.textColor = [UIColor colorWithHexString:@"#666666" withAlpha:1];
    } else {
        _statusIcon.image = [UIImage imageNamed:@"new_todaylive_icon4"];
        _statusLabel.text = @"正在视频";
        _statusLabel.textColor = [UIColor whiteColor];
    }
}

@end

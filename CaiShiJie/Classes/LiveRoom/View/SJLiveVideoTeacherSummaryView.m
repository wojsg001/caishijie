//
//  SJLiveVideoTeacherSummaryView.m
//  CaiShiJie
//
//  Created by user on 18/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveVideoTeacherSummaryView.h"
#import "SJNewLiveVideoTeacherModel.h"

@interface SJLiveVideoTeacherSummaryView ()

@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *delButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewWidth;

@end

@implementation SJLiveVideoTeacherSummaryView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headIcon.layer.cornerRadius = self.headIcon.height/2;
    self.headIcon.layer.masksToBounds = YES;
    self.contentTextView.showsVerticalScrollIndicator = NO;
    self.contentTextView.showsHorizontalScrollIndicator = NO;
    
    [self.nameLabel sizeToFit];
    self.titleViewWidth.constant = CGRectGetWidth(self.headIcon.frame) + CGRectGetWidth(self.nameLabel.frame) + 11;
}

- (void)setModel:(SJNewLiveVideoTeacherModel *)model {
    if (_model != model) {
        _model = model;
    }
    [_headIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"photo_n_300px"]];
    _nameLabel.text = [NSString stringWithFormat:@"%@简介",_model.nickname];
    [_nameLabel sizeToFit];
    self.titleViewWidth.constant = CGRectGetWidth(self.headIcon.frame) + CGRectGetWidth(self.nameLabel.frame) + 11;
    if (_model.introduction == nil) {
        _contentTextView.text = @"暂无";
    } else {
        _contentTextView.text = _model.introduction;
    }
}

- (IBAction)delButtonClick:(id)sender {
    if (self.removePopupViewBlock) {
        self.removePopupViewBlock();
    }
}

@end

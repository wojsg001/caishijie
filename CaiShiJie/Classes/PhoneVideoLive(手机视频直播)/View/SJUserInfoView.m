//
//  SJUserInfoView.m
//  CaiShiJie
//
//  Created by user on 16/8/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJUserInfoView.h"
#import "SJVideoTeacherInfoModel.h"

@interface SJUserInfoView ()

@property (nonatomic, strong) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end

@implementation SJUserInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = self.bounds;
        _innerView.layer.cornerRadius = 10;
        _innerView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = 30;
        _headImageView.layer.masksToBounds = YES;
        [self addSubview:_innerView];
    }
    return self;
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    _nameLabel.text = _model.nickname;
    _summaryLabel.text = _model.user_summary;
}

- (IBAction)clickMoreButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (self.clickMoreButtonBlock) {
        self.clickMoreButtonBlock(button);
    }
}

- (IBAction)clickDeleteButton:(id)sender {
    if (self.clickDeleteButtonBlock) {
        self.clickDeleteButtonBlock();
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

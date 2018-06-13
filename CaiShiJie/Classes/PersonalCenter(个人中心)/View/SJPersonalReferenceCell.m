//
//  SJPersonalReferenceCell.m
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalReferenceCell.h"
#import "UIColor+helper.h"
#import "SJMyNeiCan.h"
#import "SJUserInfo.h"

@interface SJPersonalReferenceCell ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;

@end

@implementation SJPersonalReferenceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.topView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.topView.layer.borderWidth = 0.5;
    self.payButton.layer.cornerRadius = 5.0;
    self.payButton.layer.masksToBounds = YES;
    self.statusButton.layer.cornerRadius = 6.5;
    self.statusButton.layer.masksToBounds = YES;
    self.headImage.layer.cornerRadius = self.headImage.height / 2;
    self.headImage.layer.masksToBounds = YES;
    self.lineHeightConstraint.constant = 0.5;
}

- (void)setModel:(SJMyNeiCan *)model {
    if (_model != model) {
        _model = model;
    }
    
    [_headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    _nameLabel.text = _model.nickname;
    _titleLabel.text = _model.title;
    _timeLabel.text = [NSString stringWithFormat:@"服务期：%@至%@", _model.start_at, _model.end_at];
    _countLabel.text = [NSString stringWithFormat:@"%@人订阅", _model.pay_count];
    _priceLabel.text = [NSString stringWithFormat:@"¥%@", _model.price];
    
    if ([_model.status isEqualToString:@"0"]) {
        [_statusButton setTitle:@"更新中" forState:UIControlStateNormal];
        [_statusButton setBackgroundColor:[UIColor colorWithHexString:@"#ffb024" withAlpha:1]];
        if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
            [_payButton setBackgroundColor:[UIColor colorWithHexString:@"#d94332" withAlpha:1]];
            return;
        }
        
        if ([_model.isPay isEqualToString:@"0"]) {
            // 已经购买
            [_payButton setBackgroundColor:[UIColor colorWithHexString:@"#999999" withAlpha:1]];
        } else {
            // 未购买
            [_payButton setBackgroundColor:[UIColor colorWithHexString:@"#d94332" withAlpha:1]];
        }
    } else if ([_model.status isEqualToString:@"1"]) {
        [_statusButton setTitle:@"更新中" forState:UIControlStateNormal];
        [_statusButton setBackgroundColor:[UIColor colorWithHexString:@"#ffb024" withAlpha:1]];
        [_payButton setBackgroundColor:[UIColor colorWithHexString:@"#999999" withAlpha:1]];
    } else if ([_model.status isEqualToString:@"2"]) {
        [_statusButton setTitle:@"结束" forState:UIControlStateNormal];
        [_statusButton setBackgroundColor:[UIColor colorWithHexString:@"#999999" withAlpha:1]];
        [_payButton setBackgroundColor:[UIColor colorWithHexString:@"#999999" withAlpha:1]];
    }
}

- (IBAction)clickPayButton:(id)sender {
    if ([_model.status isEqualToString:@"0"] && ![_model.isPay isEqualToString:@"0"]) {
        if (self.clickedPayButtonBlock) {
            self.clickedPayButtonBlock();
        }
    }
}

@end

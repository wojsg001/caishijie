//
//  SJPersonalOldLiveHeadView.m
//  CaiShiJie
//
//  Created by user on 18/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalOldLiveHeadView.h"
#import "UIColor+helper.h"

@interface SJPersonalOldLiveHeadView ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *liveButton;
@property (weak, nonatomic) IBOutlet UILabel *peopleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewHeightConstraint;

@end

@implementation SJPersonalOldLiveHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.backgroundView.layer.borderWidth = 0.5f;
    self.lineHeightConstraint.constant = 0.5f;
    self.backgroundViewHeightConstraint.constant = 35.5f;
    self.peopleCountLabel.hidden = YES;
}

- (void)setInfoDic:(NSDictionary *)infoDic {
    _infoDic = infoDic;

    self.peopleCountLabel.hidden = NO;
    self.backgroundViewHeightConstraint.constant = 75.0f;
    
    [_liveButton setTitle:@"正在直播" forState:UIControlStateNormal];
    self.peopleCountLabel.text = [NSString stringWithFormat:@"人气：%@", NonEmptyString(_infoDic[@"total_count"])];
    self.liveTitleLabel.text = [NSString stringWithFormat:@"%@", NonEmptyString(_infoDic[@"title"])];
}

- (IBAction)liveButtonClicked:(id)sender {
    SJLog(@"点击了按钮");
    if (self.liveButtonClickBlock) {
        //self.liveButtonClickBlock();
    }
}

@end

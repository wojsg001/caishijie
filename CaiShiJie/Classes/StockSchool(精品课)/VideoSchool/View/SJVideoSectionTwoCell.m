//
//  SJVideoSectionTwoCell.m
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoSectionTwoCell.h"
#import "SJVideoInfoModel.h"

@interface SJVideoSectionTwoCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *clicksLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end

@implementation SJVideoSectionTwoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(SJVideoInfoModel *)model {
    _model = model;
    
    self.titleLabel.text = model.course_name;
    self.teacherLabel.text = model.nickname;
    self.summaryLabel.text = [model.introduce stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    self.clicksLabel.text = model.clickCount;
    
}

- (IBAction)clickEvent:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.allBtnClickEventBlock) {
        self.allBtnClickEventBlock(btn.tag);
    }
}

@end

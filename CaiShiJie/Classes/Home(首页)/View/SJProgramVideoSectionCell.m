//
//  SJProgramVideoSectionCell.m
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJProgramVideoSectionCell.h"
#import "SJProgramVideoInfoModel.h"

@interface SJProgramVideoSectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *programImgView;
@property (weak, nonatomic) IBOutlet UILabel *programNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *programTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *programEmceeLabel;


@end

@implementation SJProgramVideoSectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(SJProgramVideoInfoModel *)model {
    _model = model;

    self.programNameLabel.text = model.name;
    self.programTimeLabel.text = model.start_at;
    self.programEmceeLabel.text = model.emcee;
    [self.programImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, model.img]] placeholderImage:[UIImage imageNamed:@"neican_photo"]];
}

@end

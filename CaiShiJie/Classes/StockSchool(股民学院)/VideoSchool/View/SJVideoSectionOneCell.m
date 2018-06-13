//
//  SJVideoSectionOneCell.m
//  CaiShiJie
//
//  Created by user on 16/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoSectionOneCell.h"
#import "SJVideoInfoListModel.h"

@interface SJVideoSectionOneCell()

@property (weak, nonatomic) IBOutlet UIImageView *stateIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SJVideoSectionOneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(SJVideoInfoListModel *)model {
    _model = model;
    
    _titleLabel.text = _model.period_name;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_model.created_at intValue]];
    NSString *datestr = [NSString dateWithDate:date];
    _timeLabel.text = datestr;
    
    if ([_model.item_type isEqualToString:@"1"]) {
        //代表视频
        self.stateIcon.image =[UIImage imageNamed:@"live_about_icon"];
    } else {
        //代表文字
        self.stateIcon.image =[UIImage imageNamed:@"live_about_icon2"];
    }
}

@end

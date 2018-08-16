//
//  SJVodVideoSectionOneCell.m
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVodVideoSectionOneCell.h"
#import "SJVodVideoInfoListModel.h"

@interface SJVodVideoSectionOneCell()

@property (weak, nonatomic) IBOutlet UIImageView *stateIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SJVodVideoSectionOneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(SJVodVideoInfoListModel *)model {
    _model = model;
    
    _titleLabel.text = [NSString stringWithFormat:@"%@",_model.title];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_model.created_at intValue]];
    NSString *datestr = [NSString dateWithDate:date];
    _timeLabel.text = datestr;
    
//    if ([_model.item_type isEqualToString:@"1"]) {
        //代表视频
        self.stateIcon.image =[UIImage imageNamed:@"live_about_icon"];
//    } else {
//        //代表文字
//        self.stateIcon.image =[UIImage imageNamed:@"live_about_icon2"];
//    }
}

@end

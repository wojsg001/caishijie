//
//  SJHistoryTopCell.m
//  CaiShiJie
//
//  Created by user on 16/1/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHistoryTopCell.h"

@interface SJHistoryTopCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SJHistoryTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy"];
    
    self.label.text = [NSString stringWithFormat:@"%@年", [format stringFromDate:date]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

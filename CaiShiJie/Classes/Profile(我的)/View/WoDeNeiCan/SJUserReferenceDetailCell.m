//
//  SJUserReferenceDetailCell.m
//  CaiShiJie
//
//  Created by user on 16/3/28.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJUserReferenceDetailCell.h"
#import "SJMyNeiCan.h"

@interface SJUserReferenceDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *head_imgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *payCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *payTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation SJUserReferenceDetailCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.head_imgView.layer.cornerRadius = 5;
    self.head_imgView.layer.masksToBounds = YES;
}

- (void)setModel:(SJMyNeiCan *)model {
    _model = model;
    
    [_head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"neican_teacher_photo"]];
    _nickNameLabel.text = _model.nickname;
    _payCountLabel.text = [NSString stringWithFormat:@"%@人订阅",_model.pay_count];
    
    _serviceDateLabel.text = [NSString stringWithFormat:@"服务期：%@至%@",[self dateStringWithString:_model.start_at DateFormat:@"MM-dd"],[self dateStringWithString:_model.end_at DateFormat:@"MM-dd"]];
    
    _priceLabel.text = [NSString stringWithFormat:@"¥%@",_model.price];
    _payTimeLabel.text = [NSString stringWithFormat:@"购买时间：%@",_model.pay_created_at];
    
    
    if ([_model.status isEqualToString:@"2"]) {
        // 已结束
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon_end"] forState:UIControlStateNormal];
    } else {
        [_statusBtn setImage:[UIImage imageNamed:@"neican_icon"] forState:UIControlStateNormal];
    }
    
}

- (NSString *)dateStringWithString:(NSString *)time DateFormat:(NSString *)dateFormat
{
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = dateFormat;
    
    NSInteger interval = [time integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

@end

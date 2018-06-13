//
//  SJHisReferenceDetailCell.m
//  CaiShiJie
//
//  Created by user on 16/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHisReferenceDetailCell.h"
#import "SJMyNeiCan.h"

@interface SJHisReferenceDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *head_imgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *payCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@end

@implementation SJHisReferenceDetailCell

- (void)awakeFromNib {
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
    
    
    if ([_model.status isEqualToString:@"0"]) {
        // 可购买
        if ([_model.ispay isEqualToString:@"1"]) {
            [_payBtn setImage:[UIImage imageNamed:@"neican_btn2"] forState:UIControlStateNormal];
        } else {
            [_payBtn setImage:[UIImage imageNamed:@"neican_btn1"] forState:UIControlStateNormal];
        }
    } else {
        // 结束购买
        [_payBtn setImage:[UIImage imageNamed:@"neican_btn_end"] forState:UIControlStateNormal];
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

- (IBAction)ClickPayButton:(id)sender
{
    if ([_model.status isEqualToString:@"0"] && ![_model.ispay isEqualToString:@"1"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPayButtonWith:)]) {
            [self.delegate didClickPayButtonWith:_model];
        }
    }
}

@end

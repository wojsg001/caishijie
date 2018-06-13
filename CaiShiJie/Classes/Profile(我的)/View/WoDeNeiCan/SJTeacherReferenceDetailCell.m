//
//  SJTeacherReferenceDetailCell.m
//  CaiShiJie
//
//  Created by user on 16/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJTeacherReferenceDetailCell.h"
#import "SJMyNeiCan.h"
#import "UIImageView+WebCache.h"
#import "SJToken.h"
#import "SJNetManager.h"

@interface SJTeacherReferenceDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *serviceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *payCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *alreadyStopSellBtn;
@property (weak, nonatomic) IBOutlet UIButton *modifyServiceDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *modifyPriceBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopSellBtn;
@property (weak, nonatomic) IBOutlet UIButton *addReferenceBtn;

@end

@implementation SJTeacherReferenceDetailCell

- (void)setModel:(SJMyNeiCan *)model {
    _model = model;
    
    _serviceDateLabel.text = [NSString stringWithFormat:@"服务期：%@至%@",[self dateStringWithString:_model.start_at DateFormat:@"MM-dd"],[self dateStringWithString:_model.end_at DateFormat:@"MM-dd"]];
    
    _payCountLabel.text = [NSString stringWithFormat:@"%@人订阅",_model.pay_count];
    _priceLabel.text = [NSString stringWithFormat:@"价格：¥%@",_model.price];
    
    
    if ([_model.status isEqualToString:@"0"]) {
        // 更新中
        _alreadyStopSellBtn.hidden = YES;
        
        _modifyPriceBtn.hidden = NO;
        _modifyServiceDateBtn.hidden = NO;
        _stopSellBtn.hidden = NO;
        
        [_addReferenceBtn setImage:[UIImage imageNamed:@"neican_btn1-1"] forState:UIControlStateNormal];
    } else if ([_model.status isEqualToString:@"1"]) {
        // 结束订阅
        _alreadyStopSellBtn.hidden = YES;
        
        _modifyPriceBtn.hidden = YES;
        _modifyServiceDateBtn.hidden = NO;
        _stopSellBtn.hidden = YES;
        
        [_addReferenceBtn setImage:[UIImage imageNamed:@"neican_btn1-1"] forState:UIControlStateNormal];
        
    } else if ([_model.status isEqualToString:@"2"]) {
        // 已结束
        _alreadyStopSellBtn.hidden = NO;
        
        _modifyPriceBtn.hidden = YES;
        _modifyServiceDateBtn.hidden = YES;
        _stopSellBtn.hidden = YES;
        
        [_addReferenceBtn setImage:[UIImage imageNamed:@"neican_btn2-1"] forState:UIControlStateNormal];
    }
}

- (NSString *)dateStringWithString:(NSString *)time DateFormat:(NSString *)dateFormat {
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = dateFormat;
    
    NSInteger interval = [time integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [fmt stringFromDate:date];
}

#pragma mark - 点击修改价格按钮
- (IBAction)ClickModifyPriceBtn:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ClickModifyPriceButton)]) {
        [self.delegate ClickModifyPriceButton];
    }
}

#pragma mark - 点击修改服务期按钮
- (IBAction)ClickModifyServiceDateBtn:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ClickModifyServiceDateButton)]) {
        [self.delegate ClickModifyServiceDateButton];
    }
}

#pragma mark - 点击停止销售按钮
- (IBAction)ClickStopSellBtn:(id)sender
{
    SJToken *instance = [SJToken sharedToken];
    
    NSDictionary *dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":_model.reference_id};
    [[SJNetManager sharedNetManager] stopSellReferenceWithDict:dic success:^(NSDictionary *dict) {
        SJLog(@"%@",dict);
        [MBHUDHelper showWarningWithText:dict[@"data"]];
        
        if ([dict[@"states"] isEqualToString:@"1"]) {
            // 如果停止销售成功刷新界面
            if (self.delegate && [self.delegate respondsToSelector:@selector(SJTeacherReferenceDetailCellRefreshSuperView)]) {
                [self.delegate SJTeacherReferenceDetailCellRefreshSuperView];
            }
        }

    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 点击追加内参按钮
- (IBAction)ClickAddReferenceBtn:(id)sender
{
    if ([_model.status isEqualToString:@"2"]) {
        // 内参服务已结束，可以创建新内参
        if (self.delegate && [self.delegate respondsToSelector:@selector(SJTeacherReferenceDetailCellCreateNewReference)]) {
            [self.delegate SJTeacherReferenceDetailCellCreateNewReference];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(SJTeacherReferenceDetailAddReference)]) {
            [self.delegate SJTeacherReferenceDetailAddReference];
        }
    }
}

@end

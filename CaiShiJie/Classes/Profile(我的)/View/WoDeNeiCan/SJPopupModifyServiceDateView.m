//
//  SJPopupModifyServiceDateView.m
//  CaiShiJie
//
//  Created by user on 18/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPopupModifyServiceDateView.h"
#import "LewPopupViewController.h"
#import "MHDatePicker.h"
#import "SJMyNeiCan.h"
#import "SJToken.h"
#import "SJNetManager.h"

#define kWinH [[UIScreen mainScreen] bounds].size.height
#define kWinW [[UIScreen mainScreen] bounds].size.width
// pickerView高度
#define kPVH (kWinH*0.35>230?230:(kWinH*0.35<200?200:kWinH*0.35))

@interface SJPopupModifyServiceDateView ()<MHDatePickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldEnd_atTextField;
@property (weak, nonatomic) IBOutlet UITextField *nowEnd_atTextField;
@property (nonatomic, weak) NSDate *selectDataTime; // 记录选择的时间

@property (strong, nonatomic) MHDatePicker *selectDatePicker;

@end

@implementation SJPopupModifyServiceDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        
        _innerView.frame = frame;
        _innerView.layer.cornerRadius = 5;
        _innerView.layer.masksToBounds = YES;
        
        _oldEnd_atTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
        _oldEnd_atTextField.leftViewMode = UITextFieldViewModeAlways;
        _nowEnd_atTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
        _nowEnd_atTextField.leftViewMode = UITextFieldViewModeAlways;
        
        [self addSubview:_innerView];
    }
    return self;
}

+ (instancetype)defaultPopupView
{
    return [[SJPopupModifyServiceDateView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW - 30, 270)];
}

- (void)setModel:(SJMyNeiCan *)model
{
    _model = model;
    
    self.oldEnd_atTextField.text = [self dateStringWithString:_model.end_at DateFormat:@"yyyy-MM-dd"];
    self.nowEnd_atTextField.text = [self dateStringWithString:_model.end_at DateFormat:@"yyyy-MM-dd"];
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

// 点击取消按钮
- (IBAction)dismissViewDropAction:(id)sender
{
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopBottom;
    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

// 点击确定按钮
- (IBAction)ClickOKButton:(id)sender
{
    if ([self.nowEnd_atTextField.text isEqualToString:[self dateStringWithString:_model.end_at DateFormat:@"yyyy-MM-dd"]]) {
        [MBHUDHelper showWarningWithText:@"更改的日期需要比原日期大！"];
        return;
    }
    
    SJToken *instace = [SJToken sharedToken];
    
    NSString *endtime = [NSString stringWithFormat:@"%ld",(long)[self.selectDataTime timeIntervalSince1970]];
    NSDictionary *dic = @{@"token":instace.token,@"userid":instace.userid,@"time":instace.time,@"endtime":endtime,@"targetid":_model.reference_id};
    //修改服务期
    [[SJNetManager sharedNetManager] modifyReferenceServiceDateWith:dic success:^(NSDictionary *dict) {
        [MBHUDHelper showWarningWithText:dict[@"data"]];
        if ([dict[@"states"] isEqualToString:@"1"]) {
            // 如果修改服务期成功刷新界面
            if (self.delegate && [self.delegate respondsToSelector:@selector(SJPopupModifyServiceDateViewRefreshSuperView)]) {
                [self.delegate SJPopupModifyServiceDateViewRefreshSuperView];
            }
        }

    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
    
    
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopBottom;
    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

// 点击选择日期按钮
- (IBAction)ClickChooseButton:(id)sender
{
    _selectDatePicker = [[MHDatePicker alloc] init];
    _selectDatePicker.isBeforeTime = NO;
    _selectDatePicker.minSelectDate = [NSDate dateWithTimeIntervalSince1970:[_model.end_at integerValue]]; // 设置可选择的最小时间
    _selectDatePicker.datePickerMode = UIDatePickerModeDate;
    _selectDatePicker.delegate = self;
    
    
    __weak typeof (self) weakSelf = self;
    [_selectDatePicker didFinishSelectedDate:^(NSDate *selectDataTime) {
        
        weakSelf.selectDataTime = selectDataTime;
        weakSelf.nowEnd_atTextField.text = [weakSelf dateStringWithDate:selectDataTime DateFormat:@"yyyy-MM-dd"];
        
        // 还原弹出视图位置
        if (kPVH > (SJScreenH - 270)/2)
        {
            [UIView animateWithDuration:0.2 animations:^{
                
                weakSelf.transform =  CGAffineTransformIdentity;
                
            }];
        }
        
    }];
    
    // 弹出视图上移
    if (kPVH > (SJScreenH - 270)/2)
    {
        __weak typeof (self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            
            weakSelf.transform = CGAffineTransformMakeTranslation(0, -(kPVH - (SJScreenH - 270)/2));
            
        }];
    }
    
}

- (NSString *)dateStringWithDate:(NSDate *)date DateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    NSString *str = [dateFormatter stringFromDate:date];
    return str ? str : @"";
}

#pragma mark - MHDatePickerDelegate 代理方法
- (void)dismissDatePicker
{
    __weak typeof (self) weakSelf = self;
    // 还原弹出视图位置
    if (kPVH > (SJScreenH - 270)/2)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            weakSelf.transform =  CGAffineTransformIdentity;
            
        }];
    }
}

@end

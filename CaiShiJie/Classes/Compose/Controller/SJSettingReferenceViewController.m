//
//  SJCreateNewReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/31.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJSettingReferenceViewController.h"
#import "MHDatePicker.h"

@interface SJSettingReferenceViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) MHDatePicker *selectDatePicker;

@end

@implementation SJSettingReferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleBackgroundView.layer.cornerRadius = 5;
    self.titleBackgroundView.layer.masksToBounds = YES;
    self.titleTextField.delegate = self;
    self.priceTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    
    return YES;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.addImageButton setImage:_image forState:UIControlStateNormal];
}

#pragma mark - 点击设置开始时间
- (IBAction)ClickStartTimeButton:(id)sender
{
    [self.view endEditing:YES];
    
    _selectDatePicker = [[MHDatePicker alloc] init];
    _selectDatePicker.isBeforeTime = NO;
    _selectDatePicker.datePickerMode = UIDatePickerModeDate;

    
    __weak typeof (self) weakSelf = self;
    [_selectDatePicker didFinishSelectedDate:^(NSDate *selectDataTime) {
        
        weakSelf.startTimeTextField.text = [weakSelf dateStringWithDate:selectDataTime DateFormat:@"yyyy-MM-dd"];
    }];
}

#pragma mark - 点击设置结束时间
- (IBAction)ClickEndTimeButton:(id)sender
{
    [self.view endEditing:YES];
    
    _selectDatePicker = [[MHDatePicker alloc] init];
    _selectDatePicker.isBeforeTime = NO;
    _selectDatePicker.datePickerMode = UIDatePickerModeDate;

    
    __weak typeof (self) weakSelf = self;
    [_selectDatePicker didFinishSelectedDate:^(NSDate *selectDataTime) {
        
        weakSelf.endTimeTextField.text = [weakSelf dateStringWithDate:selectDataTime DateFormat:@"yyyy-MM-dd"];
    }];
}

#pragma mark - 点击设置内参封面
- (IBAction)ClickAddImageButton:(id)sender
{
    [self.view endEditing:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAddImageButton)])
    {
        [self.delegate didClickAddImageButton];
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

@end

//
//  SJForgetPasswordViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJForgetPasswordViewController.h"
#import "SJGetIdentifyingCodeViewController.h"
#import "SJhttptool.h"

@interface SJForgetPasswordViewController ()<UITextFieldDelegate>
{
    BOOL isClickNextButton;
}
@end

@implementation SJForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"忘记密码";
    self.phoneNumberTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    isClickNextButton = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.phoneNumberTextField endEditing:YES];
}

#pragma mark - UITextFieldDelegate Method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.delPhoneNumberBtn.hidden = NO;
    self.errorView.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.delPhoneNumberBtn.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

// 点击清除手机号按钮
- (IBAction)deletePhoneNumberBtnPressed:(id)sender
{
    self.phoneNumberTextField.text = @"";
}

// 点击下一步按钮时调用
- (IBAction)nextBtnPressed:(id)sender
{
    if (isClickNextButton) {
        [MBHUDHelper showWarningWithText:@"请不要重复点击!"];
        return;
    }
    
    [self.phoneNumberTextField endEditing:YES];
    if ([self validateMobile:self.phoneNumberTextField.text]) {
        isClickNextButton = YES;
        NSString *url =[NSString stringWithFormat:@"%@/mobile/register/sendcode?target=%@",HOST,self.phoneNumberTextField.text];
        [SJhttptool GET:url paramers:nil success:^(id respose) {
            SJLog(@"%@",respose);
            isClickNextButton = NO;
            if ([respose[@"states"] isEqualToString:@"1"]) {
                // 获取验证码成功
                SJGetIdentifyingCodeViewController *identifyingVC = [[SJGetIdentifyingCodeViewController alloc] init];
                identifyingVC.phoneNumberStr =self.phoneNumberTextField.text;
                [self.navigationController pushViewController:identifyingVC animated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            SJLog(@"%@", error);
            isClickNextButton = NO;
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
    } else {
        isClickNextButton = NO;
        self.errorView.hidden = NO;
    }
}

- (BOOL)validateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

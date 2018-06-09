//
//  SJGetIdentifyingCodeViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJGetIdentifyingCodeViewController.h"
#import "SJReplacePasswordViewController.h"
#import "SJhttptool.h"

@interface SJGetIdentifyingCodeViewController ()<UITextFieldDelegate>
{
    int secondsCountDown;
    NSTimer *t;
}
@end

@implementation SJGetIdentifyingCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infoLabel.attributedText = [self getDifferentColorString];
    self.phoneNumberLabel.text = [self.phoneNumberStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    self.identifyingCodeTextField.delegate = self;
    // 创建定时器
    [self createNSTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (t != nil) {
        [t invalidate];
        t = nil;
    }
}

- (void)getphonecode{
    NSString *url =[NSString stringWithFormat:@"%@/mobile/register/sendcode?target=%@",HOST,self.phoneNumberStr];
    [SJhttptool GET:url paramers:nil success:^(id respose) {
        SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            // 收到验证码
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)createNSTimer
{
    secondsCountDown = 60;
    // 倒计时定时器
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
}

// 倒计时调用方法
- (void)timeFireMethod
{
    secondsCountDown--;
    self.dateLabel.text = [NSString stringWithFormat:@"%i",secondsCountDown];
    
    if (secondsCountDown == 0) {
        [t invalidate];
        self.dateView.hidden = YES;
        self.onceSendBtn.hidden = NO;
    }
}

- (NSMutableAttributedString *)getDifferentColorString
{
    NSString *str = @"我们已发送验证码到您的手机";
    NSMutableAttributedString *hintStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range = [[hintStr string] rangeOfString:@"验证码"];
    [hintStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:241/255.0 green:74/255.0 blue:0 alpha:1.0] range:range];
    
    return hintStr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.identifyingCodeTextField endEditing:YES];
}

#pragma mark - UITextFieldDelegate Method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // 允许点击
    self.nextBtn.enabled = YES;
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_n"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_h"] forState:UIControlStateHighlighted];
    self.errorView.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length < 1)
    {
        // 禁止点击
        self.nextBtn.enabled = NO;
        [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_next"] forState:UIControlStateNormal];
    }
}

// 点击重新发送
- (IBAction)onceSendBtnPressed:(id)sender
{
    self.dateView.hidden = NO;
    self.onceSendBtn.hidden = YES;
    [self createNSTimer];
    
    [self getphonecode];
}

// 点击下一步
- (IBAction)nextBtnPressed:(id)sender
{
    [self.identifyingCodeTextField endEditing:YES];
   
    NSString *Url =[NSString stringWithFormat:@"%@/mobile/register/validcode?target=%@&code=%@",HOST,self.phoneNumberStr,self.identifyingCodeTextField.text];
    [SJhttptool GET:Url paramers:nil success:^(id respose) {
        SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            //如果验证成功
            SJReplacePasswordViewController *replaceVC = [[SJReplacePasswordViewController alloc] init];
            replaceVC.code = self.identifyingCodeTextField.text;
            replaceVC.phonenumber = self.phoneNumberStr;
            
            [self.navigationController pushViewController:replaceVC animated:YES];
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

@end

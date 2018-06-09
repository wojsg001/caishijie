//
//  SJRegisterViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJRegisterViewController.h"
#import "SJRegisterDetailViewController.h"
#import "AFNetworking.h"

@interface SJRegisterViewController ()<UITextFieldDelegate>
{
    NSTimer *t;
    int secondsCountDown;
    BOOL isClickIdentifyingCodeBtn;
}
@end

@implementation SJRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    self.phoneNumberTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    isClickIdentifyingCodeBtn = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (t != nil) {
        [t invalidate];
        t = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.phoneNumberTextField endEditing:YES];
    [self.identifyingCodeTextField endEditing:YES];
}

// 点击获取验证码按钮式调用
- (IBAction)identifyingCodeBtnPressed:(id)sender
{
    if (isClickIdentifyingCodeBtn) {
        [MBHUDHelper showWarningWithText:@"请不要重复点击!"];
        return;
    }
    
    if ([self validateMobile:self.phoneNumberTextField.text]) {
        isClickIdentifyingCodeBtn = YES;
        NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/register/sendphonecode?target=%@",HOST,self.phoneNumberTextField.text];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 请求时提交的数据格式
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 服务器返回的数据格式
        manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            //SJLog(@"%@",tmpDict);
            isClickIdentifyingCodeBtn = NO;
            if ([tmpDict[@"states"] isEqualToString:@"1"]) {
                // 获取成功
                [self createNSTimer];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:tmpDict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            isClickIdentifyingCodeBtn = NO;
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];

    } else {
        isClickIdentifyingCodeBtn = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请输入正确的手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

// 创建定时器
- (void)createNSTimer {
    secondsCountDown = 60;
    // 倒计时定时器
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeCountdown) userInfo:nil repeats:YES];
    self.identifyingCodeBtn.hidden = YES;
    self.label.hidden = NO;
    self.dateLabel.hidden = NO;
}

// 倒计时
- (void)timeCountdown
{
    secondsCountDown--;
    self.dateLabel.text = [NSString stringWithFormat:@"%i",secondsCountDown];
    
    if (secondsCountDown == 0)
    {
        [t invalidate];
        self.identifyingCodeBtn.hidden = NO;
        self.label.hidden = YES;
        self.dateLabel.hidden = YES;
        self.dateLabel.text = @"60";
        [self.identifyingCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
    }
}

// 点击下一步按钮时调用
- (IBAction)nextBtnPressed:(id)sender
{
    if (![self validateMobile:self.phoneNumberTextField.text]) {
        [MBHUDHelper showWarningWithText:@"请输入正确的手机号"];
        return;
    } else if (self.identifyingCodeTextField.text.length < 1) {
        [MBHUDHelper showWarningWithText:@"请输入验证码"];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/register/validcode?target=%@&code=%@",HOST,self.phoneNumberTextField.text,self.identifyingCodeTextField.text];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SJLog(@"%@",tmpDict);
        
        if ([tmpDict[@"states"] isEqualToString:@"1"]) {
            // 验证成功
            SJRegisterDetailViewController *registerDetailVC = [[SJRegisterDetailViewController alloc] init];
            registerDetailVC.phoneNumber = self.phoneNumberTextField.text;
            [self.navigationController pushViewController:registerDetailVC animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:tmpDict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"请求失败,%@",error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - UITextFieldDelegate Method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // 允许点击
    self.nextBtn.enabled = YES;
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_n"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_h"] forState:UIControlStateHighlighted];
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
    NSString * CT = @"^1((70|76|77|78|33|53|8[09])[0-9]|349)\\d{7}$";
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

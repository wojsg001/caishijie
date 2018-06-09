//
//  SJOtherRegisterViewController.m
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJOtherRegisterViewController.h"
#import "SJRegisterSucceedViewController.h"
#import "AFNetworking.h"

@interface SJOtherRegisterViewController ()<UITextFieldDelegate>
{
    NSTimer *t;
    int secondsCountDown;
}

@end

@implementation SJOtherRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    self.userNameLabel.delegate = self;
    self.phoneNumberTextField.delegate = self;
    
    // 第三方登录时，给用户名赋值
    if (self.dict != nil)
    {
        self.userNameLabel.text = self.dict[@"nickname"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    [self.userNameLabel endEditing:YES];
}

// 点击获取验证码按钮式调用
- (IBAction)identifyingCodeBtnPressed:(id)sender
{
    if ([self validateMobile:self.phoneNumberTextField.text]) {
        [MBProgressHUD showMessage:@"获取中..." toView:self.view];
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
            [MBProgressHUD hideHUDForView:self.view];
            if ([tmpDict[@"states"] isEqualToString:@"1"]) {
                secondsCountDown = 60;
                // 倒计时定时器
                t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeCountdown) userInfo:nil repeats:YES];
                self.identifyingCodeBtn.hidden = YES;
                self.label.hidden = NO;
                self.dateLabel.hidden = NO;
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:tmpDict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            SJLog(@"请求失败,%@",error);
            [MBProgressHUD hideHUDForView:self.view];
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请输入正确的手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
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

// 点击确定按钮时调用
- (IBAction)nextBtnPressed:(id)sender
{
    [MBProgressHUD showMessage:@"验证中..." toView:self.view];
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
        [MBProgressHUD hideHUDForView:self.view];
        // 验证成功时
        if ([tmpDict[@"states"] isEqualToString:@"1"]) {
            // 开始验证注册
            [self begintestRegister];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:tmpDict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"请求失败,%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

// 开始验证注册
- (void)begintestRegister
{
    if (![self validateMobile:self.phoneNumberTextField.text]) {
        [MBHUDHelper showWarningWithText:@"请输入正确的手机号"];
        return;
    } else if (self.userNameLabel.text.length < 2 || self.userNameLabel.text.length > 16) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请输入正确的昵称(昵称仅可以是中文，字母，数字组合的2~16个字符)" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [MBProgressHUD showMessage:@"注册中..." toView:self.view];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/register/oauth",HOST];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    // 构建请求参数
    NSMutableDictionary *mDict = [self.dict mutableCopy];
    [mDict removeObjectForKey:@"nickname"];
    mDict[@"nickname"] = self.userNameLabel.text;
    mDict[@"phone"] = self.phoneNumberTextField.text;
    //SJLog(@"%@",mDict);
    [manager POST:urlStr parameters:mDict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view];
        NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SJLog(@"+++%@",tmpDict);
        
        if ([tmpDict[@"states"] isEqualToString:@"1"]) {
            // 获取数据成功
            SJRegisterSucceedViewController *successVC = [[SJRegisterSucceedViewController alloc] init];
            successVC.dict = mDict;
            
            [self.navigationController pushViewController:successVC animated:YES];
        } else {
            // 获取信息失败
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:tmpDict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
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
    
    if ([textField isEqual:self.userNameLabel])
    {
        // 开始编辑用户名时
        self.userNameIcon.image = [UIImage imageNamed:@"login_icon_name_h"];
        self.nameDelBtn.hidden = NO;
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length < 1)
    {
        // 禁止点击
        self.nextBtn.enabled = NO;
        [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_next"] forState:UIControlStateNormal];
    }
    
    if ([textField isEqual:self.userNameLabel])
    {
        // 结束编辑用户名时
        if (textField.text.length < 1)
        {
            self.userNameIcon.image = [UIImage imageNamed:@"login_icon_name_n"];
        }
        self.nameDelBtn.hidden = YES;
    }

}

// 删除输入文本框的文字
- (IBAction)deleteNameBtnPressed:(id)sender
{
    self.userNameLabel.text = @"";
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

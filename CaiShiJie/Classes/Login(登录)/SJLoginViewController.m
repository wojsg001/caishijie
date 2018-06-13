//
//  SJLoginViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/25.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJLoginViewController.h"
#import "SJRegisterViewController.h"
#import "SJForgetPasswordViewController.h"
#import "SJOtherRegisterViewController.h"
#import "SJUserInfo.h"
#import <UMShare/UMShare.h>

#define kNotificationBeginLogin @"beginLogin"

@interface SJLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userNameLabel.delegate = self;
    self.userPasswordLabel.delegate = self;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelEditing)];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:recognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

// 取消编辑
- (void)cancelEditing {
    [self.userNameLabel endEditing:YES];
    [self.userPasswordLabel endEditing:YES];
}

#pragma mark - UITextFieldDelegate Method
// 开始编辑时
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.userNameLabel]) {
        // 开始编辑用户名时
        self.userNameIcon.image = [UIImage imageNamed:@"login_icon_name_h"];
        self.nameDelBtn.hidden = NO;
    } else if ([textField isEqual:self.userPasswordLabel]) {
        // 开始编辑密码时
        self.userPasswordIcon.image = [UIImage imageNamed:@"login_icon_password_h"];
        self.passwordBtn.hidden = NO;
    }
}
// 结束编辑时
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.userNameLabel]) {
        // 结束编辑用户名时
        if (textField.text.length < 1) {
            self.userNameIcon.image = [UIImage imageNamed:@"login_icon_name_n"];
        }
        self.nameDelBtn.hidden = YES;
    } else if ([textField isEqual:self.userPasswordLabel]) {
        // 结束编辑密码时
        if (textField.text.length < 1) {
            self.userPasswordIcon.image = [UIImage imageNamed:@"login_icon_password_n"];
        }
        self.passwordBtn.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

// 点击返回
- (IBAction)backBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
// 删除输入文本框的文字
- (IBAction)deleteNameBtnPressed:(id)sender {
    self.userNameLabel.text = @"";
}
// 显示密码
- (IBAction)showPasswordBtnPressed:(id)sender {
    self.userPasswordLabel.secureTextEntry = !self.userPasswordLabel.secureTextEntry;
    
}
// 忘记密码
- (IBAction)forgetPassedBtnPressed:(id)sender {
    SJForgetPasswordViewController *forgetVC = [[SJForgetPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}
// 点击注册
- (IBAction)registerBtnPressed:(id)sender {
    SJRegisterViewController *registerVC = [[SJRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

// 普通登录
- (IBAction)loginBtnPressed:(id)sender {
    [self cancelEditing];
    
    [self loginWithUserName:self.userNameLabel.text andPassword:self.userPasswordLabel.text];
}
#pragma mark - 普通登录
- (void)loginWithUserName:(NSString *)name andPassword:(NSString *)password {
    [MBProgressHUD showMessage:@"正在登录..." toView:self.view];
    [[SJUserInfo sharedUserInfo] loginWithUserName:name andPassword:password withSuccessBlock:^(NSDictionary *dict) {
        //移除进度条
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"+++%@",dict);
        
        if ([dict[@"states"] isEqual:@"1"]) {
            NSMutableDictionary *tmpDic = [dict[@"data"] mutableCopy];
            [tmpDic removeObjectForKey:@"email"];
            //保存用户名和密码
            [SJUserDefaults setValue:self.userNameLabel.text forKey:kUserName];
            [SJUserDefaults setValue:self.userPasswordLabel.text forKey:kPassword];
            [SJUserDefaults setValue:dict[@"data"][@"user_id"] forKey:kUserid];
            [SJUserDefaults setValue:dict[@"data"][@"auth_key"] forKey:kAuth_key];
            [SJUserDefaults setObject:tmpDic forKey:kUserInfo];
            [SJUserDefaults setBool:NO forKey:kLoginType];
            [SJUserDefaults setBool:YES forKey:kSuccessLogined];
            [SJUserDefaults synchronize];
            
            // 发送登录成功的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationLoginSuccess object:nil];
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

// 使用微信登录
- (IBAction)weixinLoginBtnPressed:(id)sender {
    // 获得用户信息(获得用户信息中包含检查授权的信息了)
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:self completion:^(id result, NSError *error) {
        if (error) {
            SJLog(@"授权错误:%@", error);
        }
        
        if ([result isKindOfClass:[UMSocialUserInfoResponse class]]) {
            UMSocialUserInfoResponse *resp = result;
            // 第三方平台SDK源数据,具体内容视平台而定
            UMSocialLogInfo(@"OriginalUserProfileResponse: %@", resp.originalResponse);
            
            NSDictionary *dict = @{@"screen_name":resp.name,@"unionid":resp.originalResponse[@"unionid"]};
            [MBProgressHUD showMessage:@"请稍候..." toView:self.view];
            [self loginWithType:@"weixin" dictionary:dict];
        } else {
            SJLog(@"获取用户信息失败");
        }
    }];
}

// 使用QQ登录
- (IBAction)qqLoginBtnPressed:(id)sender {
    // 获得用户信息(获得用户信息中包含检查授权的信息了)
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:self completion:^(id result, NSError *error) {
        if (error) {
            SJLog(@"授权错误:%@", error);
        }
        
        if ([result isKindOfClass:[UMSocialUserInfoResponse class]]) {
            UMSocialUserInfoResponse *resp = result;
            // 第三方平台SDK源数据,具体内容视平台而定
            UMSocialLogInfo(@"OriginalUserProfileResponse: %@", resp.originalResponse);

            NSDictionary *dict = @{@"screen_name":resp.name,@"openid":resp.openid};
            [MBProgressHUD showMessage:@"请稍候..." toView:self.view];
            [self loginWithType:@"qq" dictionary:dict];
        } else {
            SJLog(@"获取用户信息失败");
        }
    }];
}

// 使用微博登录
- (IBAction)weiboLoginBtnPressed:(id)sender {
    // 获得用户信息(获得用户信息中包含检查授权的信息了)
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_Sina currentViewController:self completion:^(id result, NSError *error) {
        if (error) {
            SJLog(@"授权错误:%@", error);
        }
        
        if ([result isKindOfClass:[UMSocialUserInfoResponse class]]) {
            UMSocialUserInfoResponse *resp = result;
            // 第三方平台SDK源数据,具体内容视平台而定
            UMSocialLogInfo(@"OriginalUserProfileResponse: %@", resp.originalResponse);
            
            NSDictionary *dict = @{@"screen_name":resp.name,@"uid":resp.uid};
            [MBProgressHUD showMessage:@"请稍候..." toView:self.view];
            [self loginWithType:@"weibo" dictionary:dict];
        } else {
            SJLog(@"获取用户信息失败");
        }
    }];
}
#pragma mark - 第三方登录
- (void)loginWithType:(NSString *)type dictionary:(NSDictionary *)dictionary
{
    NSString *open_id = @"";
    if ([type isEqualToString:@"weibo"]) {
        open_id = dictionary[@"uid"];
    } else if ([type isEqualToString:@"weixin"]) {
        open_id = dictionary[@"unionid"];
    } else if ([type isEqualToString:@"qq"]) {
        open_id = dictionary[@"openid"];
    }

    [[SJUserInfo sharedUserInfo] loginWithType:type andOpenid:open_id withSuccessBlock:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"+++%@",dict);
        
        if ([dict[@"states"] isEqual:@"1"]) {
            NSMutableDictionary *tmpDic = [dict[@"data"] mutableCopy];
            [tmpDic removeObjectForKey:@"email"];
            //保存登录方式和openid
            [SJUserDefaults setValue:type forKey:kType];
            [SJUserDefaults setValue:open_id forKey:kOpenid];
            [SJUserDefaults setValue:dict[@"data"][@"user_id"] forKey:kUserid];
            [SJUserDefaults setValue:dict[@"data"][@"auth_key"] forKey:kAuth_key];
            [SJUserDefaults setObject:tmpDic forKey:kUserInfo];
            [SJUserDefaults setBool:YES forKey:kLoginType];
            [SJUserDefaults setBool:YES forKey:kSuccessLogined];
            [SJUserDefaults synchronize];
            
            // 发送登录成功的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationLoginSuccess object:nil];
            [self.navigationController popViewControllerAnimated:NO];
        } else if ([dict[@"states"] isEqual:@"2"]) {
            SJOtherRegisterViewController *registerVC = [[SJOtherRegisterViewController alloc] init];
            NSDictionary *userDict = @{@"type":type,@"nickname":dictionary[@"screen_name"],@"openid":open_id};
            registerVC.dict = userDict;
            
            [self.navigationController pushViewController:registerVC animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"获取用户信息失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        SJLog(@"++%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

@end

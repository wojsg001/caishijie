//
//  SJReplacePasswordViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJReplacePasswordViewController.h"
#import "SJReplaceSuccessViewController.h"
#import "SJhttptool.h"

@interface SJReplacePasswordViewController ()<UITextFieldDelegate>

@end

@implementation SJReplacePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordTextField.delegate = self;
    self.oncePasswordTextField.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelEditing];
}
// 取消编辑
- (void)cancelEditing
{
    [self.passwordTextField endEditing:YES];
    [self.oncePasswordTextField endEditing:YES];
}

// 点击确定按钮时调用
- (IBAction)okBtnPressed:(id)sender
{
    [self cancelEditing];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *oncePassword = [self.oncePasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    if (password.length == 0) {
        [MBHUDHelper showWarningWithText:@"请输入新密码"];
    } else if (password.length < 6 || password.length > 16) {
        [MBHUDHelper showWarningWithText:@"密码只能是6~16位字母和数字组成"];
    } else if (oncePassword.length == 0) {
        [MBHUDHelper showWarningWithText:@"请再次输入新密码"];
    } else if ([password isEqualToString:oncePassword]) {
        // 如果输入的两次密码一致
        NSString *url =[NSString stringWithFormat:@"%@/mobile/user/getpass",HOST];
        NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:self.phonenumber,@"phone",self.passwordTextField.text,@"paw",self.code,@"code", nil];
        
        [SJhttptool POST:url paramers:paramers success:^(id respose) {
            SJLog(@"%@",respose);
            if ([respose[@"states"] isEqualToString:@"1"]) {
                //验证成功
                SJReplaceSuccessViewController *successVC = [[SJReplaceSuccessViewController alloc] init];
                [self.navigationController pushViewController:successVC animated:YES];
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
            
        } failure:^(NSError *error) {
           [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
    } else {
        [MBHUDHelper showWarningWithText:@"两次输入的密码不一致"];
    }
}
#pragma mark - UITextFieldDelegate Method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.errorView.hidden = YES;
}

@end

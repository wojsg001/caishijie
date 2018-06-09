//
//  SJRegisterDetailViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJRegisterDetailViewController.h"
#import "SJRegisterSucceedViewController.h"
#import "AFNetworking.h"


@interface SJRegisterDetailViewController ()<UITextFieldDelegate>
{
    NSString *sex;
}
@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation SJRegisterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    self.userNameLabel.delegate = self;
    self.userPasswordLabel.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.errorView.hidden = YES;
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

// 点击屏幕取消第一响应状态
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelEditing];
}

- (void)cancelEditing
{
    [self.userNameLabel endEditing:YES];
    [self.userPasswordLabel endEditing:YES];
}

#pragma mark - UITextFieldDelegate Method
// 开始编辑时
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.errorView.hidden = YES;
    
    if ([textField isEqual:self.userNameLabel])
    {
        // 开始编辑用户名时
        self.userNameIcon.image = [UIImage imageNamed:@"login_icon_name_h"];
        self.nameDelBtn.hidden = NO;
    }
    else if ([textField isEqual:self.userPasswordLabel])
    {
        // 开始编辑密码时
        self.userPasswordIcon.image = [UIImage imageNamed:@"login_icon_password_h"];
        self.passwordBtn.hidden = NO;
    }
}
// 结束编辑时
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.userNameLabel])
    {
        // 结束编辑用户名时
        if (textField.text.length < 1)
        {
            self.userNameIcon.image = [UIImage imageNamed:@"login_icon_name_n"];
        }
        self.nameDelBtn.hidden = YES;
    }
    else if ([textField isEqual:self.userPasswordLabel])
    {
        // 结束编辑密码时
        if (textField.text.length < 1)
        {
            self.userPasswordIcon.image = [UIImage imageNamed:@"login_icon_password_n"];
        }
        self.passwordBtn.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

// 删除输入文本框的文字
- (IBAction)deleteNameBtnPressed:(id)sender
{
    self.userNameLabel.text = @"";
}
// 显示密码
- (IBAction)showPasswordBtnPressed:(id)sender
{
    self.userPasswordLabel.secureTextEntry = !self.userPasswordLabel.secureTextEntry;
}

// 点击确定按钮时调用
- (IBAction)okBtnPressed:(id)sender
{
    // 取消编辑状态
    [self cancelEditing];
    
    if (self.userNameLabel.text.length >= 2 && self.userNameLabel.text.length <= 16 && self.userPasswordLabel.text.length >= 6 && self.userPasswordLabel.text.length <= 16 && sex != nil) {
        [MBProgressHUD showMessage:@"注册中..." toView:self.view];
        NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/register/phone",HOST];
        AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
        // 请求时提交的数据格式
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 服务器返回的数据格式
        manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
        // 构建请求参数
        NSDictionary *dict = @{@"nickname":self.userNameLabel.text, @"paw":self.userPasswordLabel.text, @"phone":self.phoneNumber, @"sex":sex};
        
        [manager POST:urlStr parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            //SJLog(@"%@",tmpDict);
            [MBProgressHUD hideHUDForView:self.view];
            // 获取数据成功
            if ([tmpDict[@"states"] isEqualToString:@"1"]) {
                SJRegisterSucceedViewController *successVC = [[SJRegisterSucceedViewController alloc] initWithNibName:@"SJRegisterSucceedViewController" bundle:[NSBundle mainBundle]];
                successVC.dict = dict;
                
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

    } else {
        // 显示错误信息
        self.errorView.hidden = NO;
    }
}
// 选择性别时调用
- (IBAction)selectBtnPressed:(id)sender
{
    self.userSexIcon.image = [UIImage imageNamed:@"login_icon_gender-h"];
    UIButton *btn = sender;
    _selectedButton.selected = NO;
    btn.selected = YES;
    _selectedButton = btn;
    
    switch (btn.tag)
    {
        case 101:
            sex = @"1";
            break;
        case 102:
            sex = @"2";
            break;
        case 103:
            sex = @"3";
            break;
            
        default:
            break;
    }
}


@end

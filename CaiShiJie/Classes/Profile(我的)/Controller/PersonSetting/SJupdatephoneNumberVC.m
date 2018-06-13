//
//  SJupdatephoneNumberVC.m
//  CaiShiJie
//
//  Created by user on 16/4/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJupdatephoneNumberVC.h"
#import "SJhttptool.h"
#import "MBProgressHUD+MJ.h"
#import "AFNetworking.h"
#import "NSString+SJMD5.h"

@interface SJupdatephoneNumberVC ()
{
    int secondsCountDown;
    NSTimer *t;
}

@property (weak, nonatomic) IBOutlet UITextField *newphone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UIButton *Okbutton;
@property (weak, nonatomic) IBOutlet UIView *dateview;
@property (weak, nonatomic) IBOutlet UIButton *sendbtn;
@property (weak, nonatomic) IBOutlet UILabel *datelable;
@property (weak, nonatomic) IBOutlet UILabel *miaoshulable;

@end

@implementation SJupdatephoneNumberVC

@dynamic title;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.Okbutton.layer.cornerRadius =5;
    self.Okbutton.layer.masksToBounds =YES;
    self.dateview.layer.cornerRadius =4;
    self.dateview.layer.masksToBounds =YES;
    
    self.code.backgroundColor =RGB(255, 255, 255);
    self.newphone.backgroundColor =RGB(255, 255, 255);
    self.view.backgroundColor =RGB(245, 245, 248);
    
    self.newphone.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.newphone.layer.borderWidth = 0.5f;
    self.code.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.code.layer.borderWidth = 0.5f;
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    self.newphone.leftView = leftView1;
    self.code.leftView = leftView2;
    self.newphone.leftViewMode = UITextFieldViewModeAlways;
    self.code.leftViewMode = UITextFieldViewModeAlways;
    
    [self setUpNavgationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (t != nil) {
        [t invalidate];
        t = nil;
    }
}

- (void)createNSTimer
{
    self.dateview.backgroundColor = [UIColor whiteColor];
    
    secondsCountDown = 60;
    // 倒计时定时器
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
}

// 倒计时调用方法
- (void)timeFireMethod
{
    secondsCountDown--;
    self.datelable.text = [NSString stringWithFormat:@"%i",secondsCountDown];
    
    if (secondsCountDown == 0)
    {
        [t invalidate];
        
        self.dateview.backgroundColor = RGB(224, 224, 223);
        self.datelable.hidden = YES;
        self.miaoshulable.hidden = YES;
        self.sendbtn.hidden =NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)setUpNavgationBar
{
    self.navigationItem.title = self.title;
    if ([self.title isEqualToString:@"修改号码"]) {
        self.newphone.placeholder =@"请输入您新的手机号";
    } else {
        self.newphone.placeholder =@"请输入您新的邮箱地址";
    }
    self.code.placeholder =@"验证码";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (IBAction)okbtn:(UIButton *)sender {
    NSString *url =[NSString stringWithFormat:@"%@/mobile/user/updatephone",HOST];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",self.newphone.text,@"phone",self.code.text,@"code", nil];
    [SJhttptool POST:url paramers:paramers success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            [MBProgressHUD showSuccess:@"设置成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"验证码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络不佳，保存失败"];
    }];
    
}

- (IBAction)sendbutton:(UIButton *)sender {
    if ([self.title isEqualToString:@"修改号码"]) {
        if (self.newphone.text.length == 11) {
            NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/register/sendphonecode?target=%@",HOST,self.newphone.text];
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
                
                if ([tmpDict[@"states"] isEqualToString:@"1"]) {
                    secondsCountDown = 60;
                    // 倒计时定时器
                    self.sendbtn.hidden=YES;
                    self.datelable.hidden =NO;
                    self.miaoshulable.hidden =NO;
                    [self createNSTimer];
                    
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:tmpDict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                SJLog(@"请求失败---%@",error);
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请输入正确的手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } else {
        //发送邮箱验证码
        NSString *url =[NSString stringWithFormat:@"%@/mobile/register/sendcodeemail",HOST];
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:self.newphone.text,@"target", nil];
        [SJhttptool GET:url paramers:dict success:^(id respose) {
            SJLog(@"%@",respose);
            
            if ([respose[@"states"] isEqualToString:@"1"]) {
                
                secondsCountDown = 60;
                // 倒计时定时器
                self.sendbtn.hidden=YES;
                self.datelable.hidden =NO;
                self.miaoshulable.hidden =NO;
                [self createNSTimer];
                
            } else {
                SJLog(@"%@",respose[@"data"]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            SJLog(@"%@",error);
            [MBProgressHUD showError:@"网络不佳，请稍后重试"];
        }];
    }
}

//保存按钮
-(void)compose{
    
    NSString *url =[NSString stringWithFormat:@"%@/mobile/user/updatephone",HOST];
    
    NSString *emailurl =[NSString stringWithFormat:@"%@/mobile/user/updateemail",HOST];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    NSDictionary *emailparamers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",self.newphone.text,@"email",self.code.text,@"code", nil];
    
    
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",self.newphone.text,@"phone",self.code.text,@"code", nil];
    
    if ([self.title isEqualToString:@"修改号码"]) {
        
        [SJhttptool POST:url paramers:paramers success:^(id respose) {
            if ([respose[@"states"] isEqualToString:@"1"]) {
                [MBProgressHUD showSuccess:@"设置成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"验证码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD showError:@"保存失败"];
        }];
    } else {
        [SJhttptool POST:emailurl paramers:emailparamers success:^(id respose) {
            if ([respose[@"states"] isEqualToString:@"1"]) {
                [MBProgressHUD showSuccess:@"设置成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"验证码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD showError:@"保存失败"];
        }];
    }
}

@end

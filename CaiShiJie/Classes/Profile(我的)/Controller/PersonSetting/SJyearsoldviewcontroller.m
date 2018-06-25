//
//  SJyearsoldviewcontroller.m
//  CaiShiJie
//
//  Created by user on 18/4/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJyearsoldviewcontroller.h"
#import "SJhttptool.h"
#import "NSString+SJMD5.h"

@interface SJyearsoldviewcontroller ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SJyearsoldviewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavgationBar];
    self.view.backgroundColor =RGB(245, 245, 248);

}

- (void)setUpNavgationBar
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)compose
{
    if (self.textField.text==nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请输入QQ号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }else{
        
        NSString *url =[NSString stringWithFormat:@"%@/mobile/user/updateqq",HOST];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *user_id = [d valueForKey:kUserid];
        NSString *auth_key = [d valueForKey:kAuth_key];
        NSDate *date = [NSDate date];
        NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
        
        NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
        
        NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",self.textField.text,@"qq",nil];
        
        [SJhttptool POST:url paramers:paramers success:^(id respose) {
            NSLog(@"%@",respose);
            if ([respose[@"states"] isEqualToString:@"1"]) {
                
                [MBProgressHUD showSuccess:@"设置成功"];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                
                [MBProgressHUD showError:@"保存失败"];
                
            }
            
        } failure:^(NSError *error) {
            
            [MBProgressHUD showError:@"网络不佳，保存失败"];
            
            
        }];
    }
}

@end

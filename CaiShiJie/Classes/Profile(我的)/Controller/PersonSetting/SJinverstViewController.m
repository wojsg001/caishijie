//
//  SJinverstViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJinverstViewController.h"
#import "SJhttptool.h"
#import "NSString+SJMD5.h"
#import "MBProgressHUD+MJ.h"

@interface SJinverstViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SJinverstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupnavigationbar];
    self.view.backgroundColor =RGB(245, 245, 248);
    
}

-(void)setupnavigationbar{
    
    self.navigationItem.title =@"投资年限";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
  
}

-(void)compose
{
    NSString *url =[NSString stringWithFormat:@"%@/mobile/user/investmentyear",HOST];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",self.textField.text,@"year",nil];
    [SJhttptool POST:url paramers:paramers success:^(id respose) {
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:@"保存失败"];
            
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络不佳"];
        
    }];
}


@end

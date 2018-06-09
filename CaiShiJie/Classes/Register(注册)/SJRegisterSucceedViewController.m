//
//  SJRegisterSucceedViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJRegisterSucceedViewController.h"
#import "SJUserInfo.h"

@interface SJRegisterSucceedViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation SJRegisterSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    
    self.infoLabel.attributedText = [self getDifferentColorString];
}

- (NSMutableAttributedString *)getDifferentColorString
{
    NSString *str =[NSString stringWithFormat:@"亲爱的%@，欢迎加入财视界。",self.dict[@"nickname"]];

    NSMutableAttributedString *hintStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range1 = [[hintStr string] rangeOfString:self.dict[@"nickname"]];
    [hintStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:241/255.0 green:74/255.0 blue:0 alpha:1.0] range:range1];
    NSRange range2 = [[hintStr string] rangeOfString:@"财视界"];
    [hintStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:241/255.0 green:74/255.0 blue:0 alpha:1.0] range:range2];
    
    return hintStr;
}

- (IBAction)LoginBtnPressed:(id)sender
{
    [self saveUserInfo];
}

- (void)saveUserInfo
{
    //保存用户名和密码
    if (self.dict[@"openid"]) {
        [self otherLoginType];
    } else {
        [self commonLoginType];
    }
}

- (void)commonLoginType
{
    SJUserInfo *u = [SJUserInfo sharedUserInfo];
    [u loginWithUserName:self.dict[@"nickname"] andPassword:self.dict[@"paw"] withSuccessBlock:^(NSDictionary *dict) {
        //SJLog(@"用户信息%@",dict);
        if ([dict[@"states"] isEqual:@"1"]) {
            NSMutableDictionary *tmpDic = [dict[@"data"] mutableCopy];
            [tmpDic removeObjectForKey:@"email"];
            [SJUserDefaults setValue:self.dict[@"nickname"] forKey:kUserName];
            [SJUserDefaults setValue:self.dict[@"paw"] forKey:kPassword];
            [SJUserDefaults setBool:NO forKey:kLoginType];
            [SJUserDefaults setBool:YES forKey:kSuccessLogined];
            [SJUserDefaults setValue:dict[@"data"][@"user_id"] forKey:kUserid];
            [SJUserDefaults setValue:dict[@"data"][@"auth_key"] forKey:kAuth_key];
            [SJUserDefaults setObject:tmpDic forKey:kUserInfo];
            [SJUserDefaults synchronize];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
    
}

- (void)otherLoginType
{
    SJUserInfo *u = [SJUserInfo sharedUserInfo];
    
    [u loginWithType:self.dict[@"type"] andOpenid:self.dict[@"openid"] withSuccessBlock:^(NSDictionary *dict) {
        
        if ([dict[@"states"] isEqual:@"1"]) {
            NSMutableDictionary *tmpDic = [dict[@"data"] mutableCopy];
            [tmpDic removeObjectForKey:@"email"];
            [SJUserDefaults setValue:self.dict[@"type"] forKey:kType];
            [SJUserDefaults setValue:self.dict[@"openid"] forKey:kOpenid];
            [SJUserDefaults setBool:YES forKey:kLoginType];
            [SJUserDefaults setBool:YES forKey:kSuccessLogined];
            [SJUserDefaults setValue:dict[@"data"][@"user_id"] forKey:kUserid];
            [SJUserDefaults setValue:dict[@"data"][@"auth_key"] forKey:kAuth_key];
            [SJUserDefaults setObject:tmpDic forKey:kUserInfo];
            [SJUserDefaults synchronize];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

@end

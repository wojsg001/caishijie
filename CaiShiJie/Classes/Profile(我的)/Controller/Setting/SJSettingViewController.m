//
//  SJSettingViewController.m
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJSettingViewController.h"
#import "SJPersonsettingViewController.h"

@interface SJSettingViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation SJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            SJPersonsettingViewController *personvc =[[SJPersonsettingViewController alloc]initWithNibName:@"SJPersonsettingViewController" bundle:nil];
            personvc.title = @"个人设置";
            
            
            [self.navigationController pushViewController:personvc animated:YES];
        }
    }
    else if (indexPath.section == 1)
    {
        self.indexPath = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 102;
        
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 102)
    {
        if (buttonIndex == 1)
        {
            // 清空登录时记录的数据
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            [d removeObjectForKey:kType];
            [d removeObjectForKey:kOpenid];
            [d removeObjectForKey:kUserid];
            [d removeObjectForKey:kAuth_key];
            [d removeObjectForKey:kUserName];
            [d removeObjectForKey:kPassword];
            [d removeObjectForKey:kUserInfo];
            [d removeObjectForKey:kLoginType];
            [d removeObjectForKey:kSuccessLogined];
            [d synchronize];
            
            // 发送退出登录的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationExitLogin object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            if (self.indexPath != nil) {
                [self.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
            }
        }
    }
}


@end

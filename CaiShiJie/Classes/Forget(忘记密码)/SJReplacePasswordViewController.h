//
//  SJReplacePasswordViewController.h
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJReplacePasswordViewController : SJBaseViewController
/**
 *  输入密码
 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
/**
 *  再次输入密码
 */
@property (weak, nonatomic) IBOutlet UITextField *oncePasswordTextField;
/**
 *  错误提示
 */
@property (weak, nonatomic) IBOutlet UIView *errorView;

@property (nonatomic,copy)NSString *phonenumber;
//验证码
@property (nonatomic,copy)NSString *code;
@end

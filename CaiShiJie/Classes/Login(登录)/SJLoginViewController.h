//
//  SJLoginViewController.h
//  CaiShiJie
//
//  Created by user on 15/12/25.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJLoginViewController : SJBaseViewController
/**
 *  用户名icon
 */
@property (weak, nonatomic) IBOutlet UIImageView *userNameIcon;
/**
 *  密码icon
 */
@property (weak, nonatomic) IBOutlet UIImageView *userPasswordIcon;
/**
 *  输入用户名
 */
@property (weak, nonatomic) IBOutlet UITextField *userNameLabel;
/**
 *  输入密码
 */
@property (weak, nonatomic) IBOutlet UITextField *userPasswordLabel;
/**
 *  清除输入的用户名
 */
@property (weak, nonatomic) IBOutlet UIButton *nameDelBtn;
/**
 *  显示密码
 */
@property (weak, nonatomic) IBOutlet UIButton *passwordBtn;

@end

//
//  SJForgetPasswordViewController.h
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJForgetPasswordViewController : SJBaseViewController
/**
 *  输入手机号
 */
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
/**
 *  清除手机号
 */
@property (weak, nonatomic) IBOutlet UIButton *delPhoneNumberBtn;
/**
 *  错误提示
 */
@property (weak, nonatomic) IBOutlet UIView *errorView;

@end

//
//  SJRegisterViewController.h
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJRegisterViewController : SJBaseViewController
/**
 *  手机号
 */
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
/**
 *  验证码
 */
@property (weak, nonatomic) IBOutlet UITextField *identifyingCodeTextField;
/**
 *  多少秒后重新发送
 */
@property (weak, nonatomic) IBOutlet UILabel *label;
/**
 *  获取验证码按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *identifyingCodeBtn;
/**
 *  倒计时
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
/**
 *  下一步按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

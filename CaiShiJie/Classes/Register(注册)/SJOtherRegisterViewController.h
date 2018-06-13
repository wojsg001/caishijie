//
//  SJOtherRegisterViewController.h
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJOtherRegisterViewController : SJBaseViewController

/**
 *  用户名icon
 */
@property (weak, nonatomic) IBOutlet UIImageView *userNameIcon;
/**
 *  输入用户名
 */
@property (weak, nonatomic) IBOutlet UITextField *userNameLabel;
/**
 *  清除输入的用户名
 */
@property (weak, nonatomic) IBOutlet UIButton *nameDelBtn;

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
 *  确定按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSDictionary *dict;

@end

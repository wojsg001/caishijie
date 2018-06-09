//
//  SJGetIdentifyingCodeViewController.h
//  CaiShiJie
//
//  Created by user on 15/12/28.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJGetIdentifyingCodeViewController : SJBaseViewController
/**
 *  提示信息
 */
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
/**
 *  手机号
 */
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
/**
 *  验证码
 */
@property (weak, nonatomic) IBOutlet UITextField *identifyingCodeTextField;
/**
 *  倒计时
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
/**
 *  倒计时视图
 */
@property (weak, nonatomic) IBOutlet UIView *dateView;
/**
 *  错误提示
 */
@property (weak, nonatomic) IBOutlet UIView *errorView;
/**
 *  重新发送
 */
@property (weak, nonatomic) IBOutlet UIButton *onceSendBtn;
/**
 *  接收上个页面传过来的手机号
 */
@property (nonatomic, copy) NSString *phoneNumberStr;
/**
 *  下一步按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

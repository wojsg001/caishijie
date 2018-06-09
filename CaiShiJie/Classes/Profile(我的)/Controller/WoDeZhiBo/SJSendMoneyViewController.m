//
//  SJSendMoneyViewController.m
//  CaiShiJie
//
//  Created by user on 16/9/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJSendMoneyViewController.h"
#import "SJBuyGoldCoinViewController.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "SJGoldPay.h"
#import "SJNetManager.h"

@interface SJSendMoneyViewController ()<UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backViewOne;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UIView *backViewTwo;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (nonatomic, copy) NSString *goldCount;

@end

@implementation SJSendMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backViewOne.layer.cornerRadius = 3.0f;
    self.backViewOne.layer.masksToBounds = YES;
    self.backViewOne.layer.borderWidth = 0.5f;
    self.backViewOne.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.backViewTwo.layer.cornerRadius = 3.0f;
    self.backViewTwo.layer.masksToBounds = YES;
    self.backViewTwo.layer.borderWidth = 0.5f;
    self.backViewTwo.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.goldCount = @"0";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 获取用户金币数
    [self loadUserGoldCount];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.moneyTextField endEditing:YES];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取用户金币数
- (void)loadUserGoldCount {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/getuseraccount", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *dic = @{@"userid":instance.userid, @"token":instance.token, @"time":instance.time};
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"用户总金币数：%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            self.goldCount = respose[@"data"];
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        //SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.moneyTextField endEditing:YES];
}

// 送红包
- (IBAction)sendMoneyButtonClicked:(id)sender {
    [self.moneyTextField endEditing:YES];
    NSInteger payCount = [self.moneyLabel.text integerValue];
    if (payCount < 1) {
        [MBHUDHelper showWarningWithText:@"请输入红包金额"];
    } else if ([self.goldCount integerValue] < payCount) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"金币不足,请前往充值" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往", nil];
        alert.tag = 101;
        [alert show];
    } else {
        // 赠送红包
        [self sendMoney];
    }
}

- (void)sendMoney {
    SJToken *instance = [SJToken sharedToken];
    
    SJGoldPay *goldPay = [[SJGoldPay alloc] init];
    goldPay.token = instance.token;
    goldPay.userid = instance.userid;
    goldPay.time = instance.time;
    goldPay.targetid = self.target_id;
    goldPay.itemid = @"0";
    goldPay.itemtype = @"2";
    goldPay.price = self.moneyLabel.text;
    goldPay.itemcount = @"1";

    [MBProgressHUD showMessage:@"正在处理..." toView:self.view];
    [[SJNetManager sharedNetManager] goldToPayWithParam:goldPay success:^(NSDictionary *dict) {
        //SJLog(@"%@",dict[@"data"]);
        [MBProgressHUD hideHUDForView:self.view];
        if ([dict[@"status"] isEqualToString:@"10"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [MBProgressHUD showError:@"赠送失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
        SJLog(@"%@",error);
    }];
}

// 充值金币
- (IBAction)rechargeButtonClicked:(id)sender {
    SJBuyGoldCoinViewController *buyGoldCoinVC = [[SJBuyGoldCoinViewController alloc] init];
    buyGoldCoinVC.navigationItem.title = @"充值金币";
    [self.navigationController pushViewController:buyGoldCoinVC animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > 0 && [string isEqualToString:@""]) {
        NSString *tmpStr = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        if ([tmpStr isEqualToString:@""]) {
            self.moneyLabel.text = @"0.00";
        } else {
            self.moneyLabel.text = tmpStr;
        }
    } else {
        self.moneyLabel.text = [NSString stringWithFormat:@"%@%@", textField.text,string];
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101 && buttonIndex == 1) {
        SJBuyGoldCoinViewController *buyGoldCoinVC = [[SJBuyGoldCoinViewController alloc] init];
        buyGoldCoinVC.navigationItem.title = @"充值金币";
        [self.navigationController pushViewController:buyGoldCoinVC animated:YES];
    }
}

@end

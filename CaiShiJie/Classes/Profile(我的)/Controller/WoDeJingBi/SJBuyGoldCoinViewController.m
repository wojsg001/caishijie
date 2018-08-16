//
//  SJBuyGoldCoinViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJBuyGoldCoinViewController.h"
//暂时去掉BeeCloud
//#import "BeeCloud.h"
#import "SJNetManager.h"
#import "NSString+SJMD5.h"
#import "SJBuyGoldParam.h"

//暂时去掉BeeCloud
@interface SJBuyGoldCoinViewController ()
//@interface SJBuyGoldCoinViewController ()<BeeCloudDelegate>
{
    SJNetManager *netManager;
}
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *weixinPayBtn;

@property (nonatomic, weak) UIButton *lastSelectedBtn;
@property (nonatomic, copy) NSString *billTitle;
@property (nonatomic, copy) NSString *billno;

@end

@implementation SJBuyGoldCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 默认选择支付宝
    self.lastSelectedBtn = self.weixinPayBtn;
    self.billTitle = @"金币";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //暂时去掉BeeCloud
    //[BeeCloud setBeeCloudDelegate:self];
}

//暂时去掉BeeCloud
//#pragma mark - 微信、支付宝、银联、百度钱包
//- (void)doPay:(PayChannel)channel {
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
//    /**
//     按住键盘上的option键，点击参数名称，可以查看参数说明
//     **/
//    BCPayReq *payReq = [[BCPayReq alloc] init];
//    payReq.channel = channel; //支付渠道
//    payReq.title = self.billTitle;//订单标题
//    int totalfee =[self.moneyTextField.text intValue]*100;
//    payReq.totalFee =[NSString stringWithFormat:@"%i",totalfee];//订单价格
//    payReq.billNo = self.billno;//商户自定义订单号
//    payReq.scheme = @"payDemo";//URL Scheme,在Info.plist中配置; 支付宝必有参数
//    payReq.billTimeOut = 7200;//订单超时时间
//    payReq.viewController = self; //银联支付和Sandbox环境必填
//    payReq.optional = dict;//商户业务扩展参数，会在webhook回调时返回
//    [BeeCloud sendBCReq:payReq];
//}

#pragma mark - 生成订单号
- (void)genBillNo:(NSString *)channel {
    netManager = [SJNetManager sharedNetManager];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    SJBuyGoldParam *buyGoldParam = [[SJBuyGoldParam alloc] init];
    buyGoldParam.token = md5Auth_key;
    buyGoldParam.userid = user_id;
    buyGoldParam.time = datestr;
    buyGoldParam.price = [NSString stringWithFormat:@"%i",[self.moneyTextField.text intValue]];
    buyGoldParam.channel = channel;
    
    [netManager buyGoldWithSJBuyGoldParam:buyGoldParam success:^(NSDictionary *dict) {
        if ([dict[@"states"]isEqualToString:@"1"]) {
            NSDictionary *data =dict[@"data"];
            NSString *order_id =[NSString stringWithFormat:@"%@",data[@"order_id"]];
            //订单号
            self.billno =order_id;
        }
        
        if ([channel isEqualToString:@"WX_APP"]) {
            //暂时去掉BeeCloud
            //[self doPay:PayChannelWxApp];
        } else if ([channel isEqualToString:@"ALI_APP"]) {
            //暂时去掉BeeCloud
            //[self doPay:PayChannelAliApp];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

//暂时去掉BeeCloud
//#pragma mark - BCPay回调
//- (void)onBeeCloudResp:(BCBaseResp *)resp {
//    switch (resp.type) {
//        case BCObjsTypePayResp:
//        {
//            // 支付请求响应
//            BCPayResp *tempResp = (BCPayResp *)resp;
//
//            if (tempResp.resultCode == 0) {
//                //微信、支付宝、银联支付成功
//                [self showAlertView:resp.resultMsg];
//            } else {
//                //支付取消或者支付失败
//                [self showAlertView:[NSString stringWithFormat:@"%@ : %@",tempResp.resultMsg, tempResp.errDetail]];
//            }
//        }
//            break;
//
//        default:
//        {
//            if (resp.resultCode == 0) {
//                [self showAlertView:resp.resultMsg];
//            } else {
//                [self showAlertView:[NSString stringWithFormat:@"%@ : %@",resp.resultMsg, resp.errDetail]];
//            }
//        }
//            break;
//    }
//}

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.moneyTextField endEditing:YES];
}
// 选择支付宝支付
- (IBAction)alipaybtnPressed:(id)sender {
    if (self.lastSelectedBtn == self.alipayBtn) {
        return;
    }
    
    [self.alipayBtn setImage:[UIImage imageNamed:@"mine_charge_icon"] forState:UIControlStateNormal];
    [self.weixinPayBtn setImage:nil forState:UIControlStateNormal];
    self.lastSelectedBtn = self.alipayBtn;

}
// 选择微信支付
- (IBAction)weixinPayBtnPressed:(id)sender {
    if (self.lastSelectedBtn == self.weixinPayBtn) {
        return;
    }
    
    [self.alipayBtn setImage:nil forState:UIControlStateNormal];
    [self.weixinPayBtn setImage:[UIImage imageNamed:@"mine_charge_icon"] forState:UIControlStateNormal];
    self.lastSelectedBtn = self.weixinPayBtn;
}
// 点击下一步调用
- (IBAction)nextBtnPressed:(id)sender {
    [self.moneyTextField endEditing:YES];
    // 如果输入框为空
    if (!self.moneyTextField.text.length) {
        [self showAlertView:@"请输入充值金额!"];
        return;
    }
    
    if (self.lastSelectedBtn == self.weixinPayBtn) {
        // 得到微信支付订单
        [self genBillNo:@"WX_APP"];
    } else if (self.lastSelectedBtn == self.alipayBtn) {
        [self genBillNo:@"ALI_APP"];
    }
}

@end

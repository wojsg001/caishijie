//
//  SJGiftPayView.m
//  CaiShiJie
//
//  Created by user on 18/11/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGiftPayView.h"
#import "SJGiftModel.h"
#import "SJToken.h"
#import "SJhttptool.h"
//暂时去掉BeeCloud
//#import "BeeCloud.h"
#import "SJMixPayParam.h"
#import "MJExtension.h"

#define KGiftPayViewH 235
#define KGiftPayViewW 310

//暂时去掉BeeCloud
@interface SJGiftPayView ()
//@interface SJGiftPayView ()<BeeCloudDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *aliPayButton;
@property (weak, nonatomic) IBOutlet UIButton *weixinButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
/**
 第三方需要支付金额
 */
@property (nonatomic, copy) NSString *paygold;
/**
 第三方账单
 */
@property (nonatomic, copy) NSString *billno;

@end

@implementation SJGiftPayView

+ (void)showGiftPayViewWithGiftModel:(SJGiftModel *)model targetid:(NSString *)targetid goldCount:(NSString *)goldCount {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH)];
    view.backgroundColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:158/255.0 alpha:0.0];
    view.tag = KGiftPayViewTag;
    
    SJGiftPayView *payView = [[NSBundle mainBundle] loadNibNamed:@"SJGiftPayView" owner:nil options:nil].lastObject;
    payView.layer.cornerRadius = 10;
    payView.layer.masksToBounds = YES;
    payView.targetid = targetid;
    payView.goldCount = goldCount;
    payView.giftModel = model;
    payView.frame = CGRectMake((SJScreenW - KGiftPayViewW)/2, (SJScreenH - KGiftPayViewH)/2, KGiftPayViewW, KGiftPayViewH);
    payView.alpha = 0.0;
    [view addSubview:payView];
    [SJKeyWindow addSubview:view];
    
    [UIView animateWithDuration:0.5 animations:^{
        view.backgroundColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:158/255.0 alpha:0.6];
        payView.alpha = 1.0;
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.layer.masksToBounds = YES;
    self.cancelButton.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.cancelButton.layer.borderWidth = 0.5f;
    self.confirmButton.layer.cornerRadius = 5.0f;
    self.confirmButton.layer.masksToBounds = YES;
    
    //暂时去掉BeeCloud
    //[BeeCloud setBeeCloudDelegate:self];
}

- (IBAction)buttonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 101:
            // 支付宝
            self.aliPayButton.selected = !self.aliPayButton.selected;
            if (self.aliPayButton.selected) {
                self.weixinButton.selected = NO;
            }
            break;
        case 102:
            // 微信
            self.weixinButton.selected = !self.weixinButton.selected;
            if (self.weixinButton.selected) {
                self.aliPayButton.selected = NO;
            }
            break;
        case -1:
            // 取消
            [self removePayView];
            break;
        case 1:
            // 确定
            if (self.aliPayButton.selected == YES) {
                // 获取支付宝支付账单
                [self genBillNo:@"ALI_APP"];
            } else if (self.weixinButton.selected == YES) {
                // 获取微信支付账单
                [self genBillNo:@"WX_APP"];
            } else {
                [self showAlertView:@"请选择支付方式"];
            }
            break;
            
        default:
            break;
    }
}

- (void)genBillNo:(NSString *)channel {
    SJToken *instance = [SJToken sharedToken];
    SJMixPayParam *paramers = [[SJMixPayParam alloc]init];
    paramers.token = instance.token;
    paramers.userid = instance.userid;
    paramers.time = instance.time;
    paramers.targetid = self.targetid;
    //SJLog(@"%@",self.targetid);
    paramers.itemname = self.giftModel.gift_name;
    paramers.itemid = self.giftModel.gift_id;
    paramers.itemtype = @"1";
    
    int a = [self.giftModel.price intValue] * 100;
    int b = [_goldCount intValue] * 100;
    int value = a - b;
    if (value > 0) {
        _paygold = [NSString stringWithFormat:@"%d",value];
    }
    //应付金额
    paramers.paygold = [NSString stringWithFormat:@"%li", (long)([_paygold integerValue] / 100)];
    paramers.itemcount = @"1";
    paramers.paytype = channel;
    paramers.price = self.giftModel.price;
    
    [MBProgressHUD showMessage:@"正在处理中..."];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/pay/paybank",HOST]; //后台提供的接口
    [SJhttptool POST:urlStr paramers:paramers.keyValues success:^(id respose) {
        [MBProgressHUD hideHUD];
        SJLog(@"%@",respose);
        if ([respose[@"status"] isEqualToString:@"1"]) {
            self.billno = [NSString stringWithFormat:@"%@", respose[@"data"][@"order_id"]];
            if ([channel isEqualToString:@"WX_APP"]) {
                //暂时去掉BeeCloud
                //[self doPay:PayChannelWxApp];
            } else if ([channel isEqualToString:@"ALI_APP"]) {
                //暂时去掉BeeCloud
                //[self doPay:PayChannelAliApp];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUD];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
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
//    payReq.title = _giftModel.gift_name;//订单标题
//    payReq.totalFee = _paygold;//订单价格
//    payReq.billNo = _billno;//商户自定义订单号
//    payReq.scheme = @"payDemo";//URL Scheme,在Info.plist中配置; 支付宝必有参数
//    payReq.billTimeOut = 1800;//订单超时时间
//    //payReq.viewController = self; //银联支付和Sandbox环境必填
//    payReq.optional = dict;//商户业务扩展参数，会在webhook回调时返回
//    [BeeCloud sendBCReq:payReq];
//}

//暂时去掉BeeCloud
//#pragma mark - BCPay回调
//- (void)onBeeCloudResp:(BCBaseResp *)resp {
//    switch (resp.type) {
//        case BCObjsTypePayResp: {
//            [self removePayView];
//            // 支付请求响应
//            BCPayResp *tempResp = (BCPayResp *)resp;
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
//        default: {
//            [self removePayView];
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

- (void)setGiftModel:(SJGiftModel *)giftModel {
    _giftModel = giftModel;
    self.nameLabel.text = giftModel.gift_name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@金币",giftModel.price];
}

- (void)removePayView {
    [[SJKeyWindow viewWithTag:KGiftPayViewTag] removeFromSuperview];
}

@end

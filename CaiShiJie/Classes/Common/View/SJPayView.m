//
//  SJPayView.m
//  CaiShiJie
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPayView.h"
#import "SJGiftModel.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "BeeCloud.h"
#import "SJNetManager.h"
#import "SJGoldPay.h"

#define KPayViewH 265
#define KPayViewW 290

@interface SJPayView ()<BeeCloudDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *weixinButton;
@property (weak, nonatomic) IBOutlet UIButton *aliPayButton;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
/**
 用户余额
 */
@property (nonatomic, copy) NSString *goldCount;
/**
 第三方需要支付金额
 */
@property (nonatomic, copy) NSString *paygold;
/**
 第三方账单
 */
@property (nonatomic, copy) NSString *billno;

@end

@implementation SJPayView

+ (void)showSJPayViewWithGiftModel:(SJGiftModel *)model targetid:(NSString *)targetid itemtype:(NSString *)itemtype {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH)];
    view.backgroundColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:158/255.0 alpha:0.0];
    view.tag = KPayViewTag;
    
    SJPayView *payView = [[NSBundle mainBundle] loadNibNamed:@"SJPayView" owner:nil options:nil].lastObject;
    payView.targetid = targetid;
    payView.itemtype = itemtype;
    payView.layer.cornerRadius = 5;
    payView.layer.masksToBounds = YES;
    payView.giftModel = model;
    payView.frame = CGRectMake((SJScreenW - KPayViewW)/2, (SJScreenH - KPayViewH)/2, KPayViewW, KPayViewH);
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
    self.weixinButton.selected = NO;
    self.aliPayButton.selected = NO;
    self.weixinButton.userInteractionEnabled = NO;
    self.aliPayButton.userInteractionEnabled = NO;
    // 获取用户金币数
    [self loadUserGoldCount];
    [BeeCloud setBeeCloudDelegate:self];
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
            self.balanceLabel.text = [NSString stringWithFormat:@"余额：%@金币", self.goldCount];
            if ([_giftModel.price intValue] <= [self.goldCount intValue]) {
                // 金币充足时不允许使用第三方支付
                self.weixinButton.userInteractionEnabled = NO;
                self.aliPayButton.userInteractionEnabled = NO;
            } else {
                self.weixinButton.userInteractionEnabled = YES;
                self.aliPayButton.userInteractionEnabled = YES;
            }
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        //SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)setGiftModel:(SJGiftModel *)giftModel {
    _giftModel = giftModel;
    self.nameLabel.text = giftModel.gift_name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@金币",giftModel.price];
}

/**
 点击退出按钮
 
 @param sender Button
 */
- (IBAction)cancelButtonClicked:(id)sender {
    [self removePayView];
}
/**
 点击确定按钮
 
 @param sender Button
 */
- (IBAction)confirmButtonClicked:(id)sender {
    if (self.weixinButton.selected == YES) {
        // 获取微信支付账单
        [self genBillNo:@"WX_APP"];
    } else if (self.aliPayButton.selected == YES) {
        // 获取支付宝支付账单
        [self genBillNo:@"ALI_APP"];
    } else {
        if ([self.goldCount integerValue] < [_giftModel.price integerValue]) {
            [self showAlertView:@"金币不足，请先充值或选择其他支付方式!"];
            return;
        }
        // 金币支付
        [self giveGiftWithGold];
        [self removePayView];
    }
}
/**
 点击微信或支付宝按钮
 
 @param sender Button
 */
- (IBAction)weixinOrAliPayButtonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
            case 101:
            self.weixinButton.selected = !self.weixinButton.selected;
            if (self.weixinButton.selected == YES) {
                self.aliPayButton.selected = NO;
            }
            break;
            case 102:
            self.aliPayButton.selected = !self.aliPayButton.selected;
            if (self.aliPayButton.selected == YES) {
                self.weixinButton.selected = NO;
            }
            break;
            
        default:
            break;
    }
}
#pragma mark - 获取账单
- (void)genBillNo:(NSString *)channel {
    SJToken *instance = [SJToken sharedToken];
    SJMixPayParam *paramers = [[SJMixPayParam alloc]init];
    paramers.token = instance.token;
    paramers.userid = instance.userid;
    paramers.time = instance.time;
    paramers.targetid = self.targetid;
    SJLog(@"%@",self.targetid);
    paramers.itemname = self.giftModel.gift_name;
    paramers.itemid = self.giftModel.gift_id;
    paramers.itemtype = self.itemtype;
    
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
    [[SJNetManager sharedNetManager] mixPaywithSJMixPayParam:paramers success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUD];
        SJLog(@"%@",dict);
        if ([dict[@"status"] isEqualToString:@"1"]) {
            self.billno = [NSString stringWithFormat:@"%@", dict[@"data"][@"order_id"]];
            if ([channel isEqualToString:@"WX_APP"]) {
                [self doPay:PayChannelWxApp];
            } else if ([channel isEqualToString:@"ALI_APP"]) {
                [self doPay:PayChannelAliApp];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}
#pragma mark - 微信、支付宝、银联、百度钱包
- (void)doPay:(PayChannel)channel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    /**
     按住键盘上的option键，点击参数名称，可以查看参数说明
     **/
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel; //支付渠道
    payReq.title = _giftModel.gift_name;//订单标题
    payReq.totalFee = _paygold;//订单价格
    payReq.billNo = _billno;//商户自定义订单号
    payReq.scheme = @"payDemo";//URL Scheme,在Info.plist中配置; 支付宝必有参数
    payReq.billTimeOut = 1800;//订单超时时间
    //payReq.viewController = self; //银联支付和Sandbox环境必填
    payReq.optional = dict;//商户业务扩展参数，会在webhook回调时返回
    [BeeCloud sendBCReq:payReq];
}
#pragma mark - BCPay回调
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    switch (resp.type) {
            case BCObjsTypePayResp: {
                [self removePayView];
                // 支付请求响应
                BCPayResp *tempResp = (BCPayResp *)resp;
                if (tempResp.resultCode == 0) {
                    //微信、支付宝、银联支付成功
                    [self showAlertView:resp.resultMsg];
                } else {
                    //支付取消或者支付失败
                    [self showAlertView:[NSString stringWithFormat:@"%@ : %@",tempResp.resultMsg, tempResp.errDetail]];
                }
            }
            break;
            
            default: {
                [self removePayView];
                if (resp.resultCode == 0) {
                    [self showAlertView:resp.resultMsg];
                } else {
                    [self showAlertView:[NSString stringWithFormat:@"%@ : %@",resp.resultMsg, resp.errDetail]];
                }
            }
            break;
    }
}

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark - 金币支付
- (void)giveGiftWithGold {
    SJToken *instance = [SJToken sharedToken];
    SJGoldPay *goldPay = [[SJGoldPay alloc] init];
    goldPay.token = instance.token;
    goldPay.userid = instance.userid;
    goldPay.time = instance.time;
    goldPay.targetid = self.targetid;
    goldPay.itemid = _giftModel.gift_id;
    goldPay.itemtype = _itemtype;
    goldPay.price = _giftModel.price;
    goldPay.itemcount = @"1";
    
    [MBProgressHUD showMessage:@"正在处理..."];
    [[SJNetManager sharedNetManager] goldToPayWithParam:goldPay success:^(NSDictionary *dict) {
        SJLog(@"%@",dict[@"data"]);
        [MBProgressHUD hideHUD];
        if ([dict[@"status"] isEqualToString:@"10"]) {
            [MBProgressHUD showSuccess:@"赠送成功！"];
        } else {
            [MBProgressHUD showError:@"赠送失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)removePayView {
    [[SJKeyWindow viewWithTag:KPayViewTag] removeFromSuperview];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

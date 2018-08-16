//
//  SJVideoPayViewController.m
//  CaiShiJie
//
//  Created by user on 18/11/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoPayViewController.h"
#import "SJSchoolVideoModel.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "SJGoldPay.h"
#import "SJNetManager.h"
#import "BeeCloud.h"

@interface SJVideoPayViewController ()<BeeCloudDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *weixinButton;
@property (weak, nonatomic) IBOutlet UIButton *zhifubaoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *courseName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *courseIndroduce;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *courseTeacher;
@property (weak, nonatomic) IBOutlet UIButton *jinbiButton;
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

@implementation SJVideoPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"购买课程";
    [self setupSubviews];
    // 获取用户金币数
    [self loadUserGoldCount];
    [BeeCloud setBeeCloudDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 获取用户金额
- (void)loadUserGoldCount {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/getuseraccount", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *dic = @{@"userid":instance.userid, @"token":instance.token, @"time":instance.time};
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"用户总金额：%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            self.goldCount = respose[@"data"];
            if ([_model.course_price integerValue] <= [self.goldCount integerValue]) {
                // 金额充足不允许使用第三方支付
                self.jinbiButton.enabled = YES;
                self.jinbiButton.selected = YES;
                self.weixinButton.enabled = NO;
                self.zhifubaoButton.enabled = YES;
            } else {
                // 金额不足使用混合支付
                self.weixinButton.enabled = YES;
                self.zhifubaoButton.enabled = YES;
                self.jinbiButton.enabled = NO;
                self.weixinButton.selected = YES;
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (void)setupSubviews {
    self.centerView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.centerView.layer.borderWidth = 0.5f;
    self.bottomView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.bottomView.layer.borderWidth = 0.5f;
    self.confirmButton.layer.cornerRadius = 5;
    self.confirmButton.layer.masksToBounds = YES;
    
    self.courseName.text = [NSString stringWithFormat:@"精品课：%@",_model.course_name];
    self.courseIndroduce.text = [NSString stringWithFormat:@"简介：%@",_model.introduce];
    self.courseTeacher.text = [NSString stringWithFormat:@"老师：%@",_model.nickname];
    //self.titleLabel.text = _model.course_name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@元", _model.course_price];
    
    self.weixinButton.enabled = NO;
    self.zhifubaoButton.enabled = YES;
    self.jinbiButton.enabled = NO;
}

- (void)setModel:(SJSchoolVideoModel *)model {
    _model = model;
}

- (IBAction)buttonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 101:
            // 微信
            if (button.selected) {
                return;
            }
            self.weixinButton.selected = YES;
            self.zhifubaoButton.selected = NO;
            self.jinbiButton.selected = NO;
            break;
        case 102:
            // 支付宝
            if (button.selected) {
                return;
            }
            self.weixinButton.selected = NO;
            self.zhifubaoButton.selected = YES;
            self.jinbiButton.selected = NO;
            break;
        case 103:
            // 余额
            if (button.selected) {
                return;
            }
            self.weixinButton.selected = NO;
            self.zhifubaoButton.selected = NO;
            self.jinbiButton.selected = YES;
            break;
        case -1:
            // 确认
            if (self.weixinButton.selected == YES) {
                // 获取微信支付账单
                [self genBillNo:@"WX_APP"];
            } else if (self.zhifubaoButton.selected == YES) {
                // 获取支付宝支付账单
                [self genBillNo:@"ALI_APP"];
            } else if (self.jinbiButton.selected == YES) {
                // 金币支付
                [self giveGiftWithGold];
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
    paramers.targetid = _model.user_id;
    paramers.itemtype = @"4"; //精品课
    paramers.itemname = self.model.course_name;
    paramers.itemid = _model.course_id;
    
    
    int a = [self.model.course_price intValue];
    int b = [_goldCount intValue];
    int value = a - b;
    if (value > 0) {
        _paygold = [NSString stringWithFormat:@"%d",value];
        //差价
    }
    //应付金额
    paramers.paygold = [NSString stringWithFormat:@"%li", (long)([_paygold integerValue])];
    paramers.itemcount = @"1";
    paramers.paytype = channel;
    paramers.price = self.model.course_price;
    
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
        SJLog(@"%@", error);
        [MBProgressHUD hideHUD];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 微信、支付宝、银联
- (void)doPay:(PayChannel)channel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    /**
     按住键盘上的option键，点击参数名称，可以查看参数说明
     **/
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel; //支付渠道
    payReq.title = @"课程";//订单标题
    payReq.totalFee = [NSString stringWithFormat:@"%li", (long)([_paygold integerValue])*100];//订单价格
    payReq.billNo = _billno;//商户自定义订单号
    payReq.scheme = @"payDemo";//URL Scheme,在Info.plist中配置; 支付宝必有参数
    payReq.billTimeOut = 1800;//订单超时时间
    payReq.viewController = self; //银联支付和Sandbox环境必填
    payReq.optional = dict;//商户业务扩展参数，会在webhook回调时返回
    [BeeCloud sendBCReq:payReq];

}


#pragma mark - BCPay回调
- (void)onBeeCloudResp:(BCBaseResp *)resp {
    switch (resp.type) {
        case BCObjsTypePayResp: {
            
            // 支付请求响应
            BCPayResp *tempResp = (BCPayResp *)resp;
            if (tempResp.resultCode == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                //微信、支付宝、银联支付成功
                [self showAlertView:resp.resultMsg];
            } else {
                //支付取消或者支付失败
                [self showAlertView:[NSString stringWithFormat:@"%@ : %@",tempResp.resultMsg, tempResp.errDetail]];
            }
        }
            break;

        default: {
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
    goldPay.targetid = _model.user_id;
    goldPay.itemtype = @"20";
    goldPay.itemcount = @"1";
    
    [MBProgressHUD showMessage:@"正在处理..."];
    [[SJNetManager sharedNetManager] goldToPayWithParam:goldPay success:^(NSDictionary *dict) {
        SJLog(@"%@",dict[@"data"]);
        [MBProgressHUD hideHUD];
        if ([dict[@"status"] isEqualToString:@"10"]) {
            [self.navigationController popViewControllerAnimated:YES];
            [MBProgressHUD showSuccess:@"购买成功"];
        } else {
            [MBProgressHUD showError:@"购买失败"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUD];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

@end

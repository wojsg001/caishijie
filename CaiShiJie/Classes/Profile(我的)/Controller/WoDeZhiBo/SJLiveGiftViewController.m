//
//  SJLiveGiftViewController.m
//  CaiShiJie
//
//  Created by user on 18/11/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveGiftViewController.h"
#import "SJGivePresentCell.h"
#import "MJExtension.h"
#import "SJGiftModel.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "SJGiftPayView.h"
#import "SJhttptool.h"
#import "SJGoldPay.h"
#import "SJLoginViewController.h"
#import "SJBuyGoldCoinViewController.h"
#import "SJGiveGfitSuccessView.h"

@interface SJLiveGiftViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    SJNetManager *netManager;
    BOOL _isCanSendGift;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *giftDataArray;
@property (nonatomic, strong) UIButton *voucherButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSIndexPath *curSelIndexPath;
/**
 用户余额
 */
@property (nonatomic, copy) NSString *goldCount;
@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation SJLiveGiftViewController

- (CAEmitterLayer *)emitterLayer {
    if (_emitterLayer == nil) {
        _emitterLayer = [CAEmitterLayer layer];
        _emitterLayer.emitterPosition = CGPointMake(self.view.width - 20 - 30, self.view.height - 50);
        _emitterLayer.emitterSize = CGSizeMake(20, 0);
        _emitterLayer.emitterMode = kCAEmitterLayerOutline;
        _emitterLayer.emitterShape = kCAEmitterLayerLine;
        _emitterLayer.renderMode = kCAEmitterLayerAdditive;
        _emitterLayer.velocity = 1;
        _emitterLayer.birthRate = 2;
        _emitterLayer.seed = (arc4random() % 100) + 1;
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 1; i <= 8; i++) {
            CAEmitterCell *cell = [CAEmitterCell emitterCell];
            cell.birthRate = 1.0;
            cell.emissionLongitude = -0.2;
            cell.emissionRange = 0.11 * M_PI;
            cell.velocity = 250;
            cell.velocityRange = 150;
            cell.yAcceleration = 75;
            cell.lifetime = 2.04;
            cell.scale = 0.2;
            cell.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
            cell.spinRange = M_PI;
            cell.contents = (id) [[UIImage imageNamed:[NSString stringWithFormat:@"live_gift_icon%i", i]] CGImage];
            [array addObject:cell];
        }
        _emitterLayer.emitterCells = array;
    }
    return _emitterLayer;
}

- (NSMutableArray *)giftDataArray {
    if (_giftDataArray == nil) {
        _giftDataArray = [NSMutableArray array];
    }
    return _giftDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isCanSendGift = YES;
    self.view.backgroundColor = [UIColor blackColor];
    [self setupChildSubviews];
    // 加载礼物列表
    [self loadGiftListData];
    // 获取用户金币数
    [self loadUserGoldCount];
    // 接收禁止送礼通知(为历史视频状态时)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannotSendGift) name:KNotificationTextFieldStopEdit object:nil];
    // 接收允许送礼通知(为视频状态时)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canSendGift) name:KNotificationTextFieldAllowEdit object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
}

#pragma mark - 获取用户金币数
- (void)loadUserGoldCount {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/getuseraccount", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *dic = @{@"userid":instance.userid, @"token":instance.token, @"time":instance.time};
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"用户总金币数：%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            self.goldCount = respose[@"data"];
            [self.voucherButton setAttributedTitle:[self getAttributedStringTitleWithString:[NSString stringWithFormat:@"去充值：%@金币>>", self.goldCount]] forState:UIControlStateNormal];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (NSMutableAttributedString *)getAttributedStringTitleWithString:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:15]};
    [attributedString addAttributes:dic range:NSMakeRange(0, [attributedString string].length)];
    NSRange rangeOne = [[attributedString string] rangeOfString:@"去充值："];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f76408" withAlpha:1] range:rangeOne];
    NSRange rangeTwo = [[attributedString string] rangeOfString:@"金币>>"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f76408" withAlpha:1] range:rangeTwo];
    return attributedString;
}

- (void)setupChildSubviews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SJGivePresentCell" bundle:nil] forCellWithReuseIdentifier:@"SJGivePresentCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SJLiveGiftHeader"];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(bottomView.mas_top).offset(0);
    }];
    
    _voucherButton = [[UIButton alloc] init];
    [_voucherButton setAttributedTitle:[self getAttributedStringTitleWithString:@"去充值：0金币>>"] forState:UIControlStateNormal];
    _voucherButton.tag = -1;
    [_voucherButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_voucherButton];
    [_voucherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.centerY.mas_equalTo(bottomView);
    }];
    
    _sendButton = [[UIButton alloc] init];
    [_sendButton setTitle:@"赠送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_sendButton setBackgroundColor:[UIColor colorWithHexString:@"#a0a0a0" withAlpha:1]];
    _sendButton.layer.cornerRadius = 5;
    _sendButton.layer.masksToBounds = YES;
    _sendButton.tag = -2;
    _sendButton.enabled = NO;
    [_sendButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_sendButton];
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(bottomView);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(69);
    }];
}

#pragma mark - ClickEvent
- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case -1:
        {
            // 去充值
            SJLog(@"去充值");
            if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
                // 未登录
                SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
                [self.navigationController pushViewController:loginVC animated:YES];
                return;
            }
            if ([[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] || [[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
                // 已登录，不能送礼
                UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"暂不支持充值，敬请期待！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alerview show];
                return;
            }
            
            SJBuyGoldCoinViewController *buyGoldCoinVC = [[SJBuyGoldCoinViewController alloc] init];
            buyGoldCoinVC.navigationItem.title = @"充值金币";
            [self.navigationController pushViewController:buyGoldCoinVC animated:YES];
        }
            break;
        case -2:
        {
            // 发送
            SJLog(@"发送");
            if (_isCanSendGift == NO) {
                [MBHUDHelper showWarningWithText:@"视频已结束，不能送礼！"];
                return;
            }
            if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
                // 未登录
                SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
                [self.navigationController pushViewController:loginVC animated:YES];
                return;
            }
            if ([[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] || [[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
                // 已登录，不能送礼
                UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"暂不支持送礼，敬请期待！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alerview show];
                return;
            }
           
            SJGiftModel *model = [self.giftDataArray objectAtIndex:self.curSelIndexPath.row];
            if ([self.goldCount integerValue] < [model.price integerValue]) {
                // 金币不足使用第三方支付
                [SJGiftPayView showGiftPayViewWithGiftModel:model targetid:self.targetid goldCount:self.goldCount];
            } else {
                // 使用金币支付
                [self giveGiftWithGold:model];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 金币支付
- (void)giveGiftWithGold:(SJGiftModel *)model {
    SJToken *instance = [SJToken sharedToken];
    SJGoldPay *goldPay = [[SJGoldPay alloc] init];
    goldPay.token = instance.token;
    goldPay.userid = instance.userid;
    goldPay.time = instance.time;
    goldPay.targetid = self.targetid;
    goldPay.itemid = model.gift_id;
    goldPay.itemtype = @"1";
    goldPay.price = model.price;
    goldPay.itemcount = @"1";
    
    [MBProgressHUD showMessage:@"正在处理..."];
    [[SJNetManager sharedNetManager] goldToPayWithParam:goldPay success:^(NSDictionary *dict) {
        SJLog(@"%@",dict[@"data"]);
        [MBProgressHUD hideHUD];
        if ([dict[@"status"] isEqualToString:@"10"]) {
            [SJGiveGfitSuccessView showSuccessViewToView:self.view];
        } else {
            [MBProgressHUD showError:@"赠送失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 获取礼物列表信息
- (void)loadGiftListData {
    netManager = [SJNetManager sharedNetManager];
    [netManager requestGiftListInfoSuccess:^(NSDictionary *dict) {
        NSArray *tmpArr = [SJGiftModel objectArrayWithKeyValuesArray:dict[@"gift"]];
        if (tmpArr.count) {
            [self.giftDataArray addObjectsFromArray:tmpArr];
        }
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

#pragma mark - 不能送礼
- (void)cannotSendGift {
    _isCanSendGift = NO;
}

#pragma mark - 可以送礼
- (void)canSendGift {
    _isCanSendGift = YES;
}

- (void)loginSuccess {
    [self loadUserGoldCount];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJGivePresentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJGivePresentCell" forIndexPath:indexPath];

    if (indexPath == self.curSelIndexPath) {
        cell.selectButton.selected = YES;
    } else {
        cell.selectButton.selected = NO;
    }
    if (self.giftDataArray.count) {
        cell.giftModel = self.giftDataArray[indexPath.row];
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemW = (SJScreenW - 10) /4;
    return CGSizeMake(itemW, itemW + 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SJLiveGiftHeader" forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"给视频的老师送上礼物吧！";
        label.textColor = [UIColor colorWithHexString:@"#444444" withAlpha:1];
        label.font = [UIFont systemFontOfSize:15];
        [header addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(header);
        }];
        return header;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SJScreenW, 45);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SJGivePresentCell *newCell = (SJGivePresentCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.curSelIndexPath == nil) {
        newCell.selectButton.selected = YES;
        self.curSelIndexPath = indexPath;
        _sendButton.enabled = YES;
        _sendButton.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
        // 添加emitterLayer
        [self.view.layer addSublayer:self.emitterLayer];
    } else if (indexPath == self.curSelIndexPath) {
        newCell.selectButton.selected = NO;
        self.curSelIndexPath = nil;
        _sendButton.enabled = NO;
        _sendButton.backgroundColor = [UIColor colorWithHexString:@"#a0a0a0" withAlpha:1];
        // 移除emitterLayer
        [self.emitterLayer removeFromSuperlayer];
    } else {
        SJGivePresentCell *oldCell = (SJGivePresentCell *)[collectionView cellForItemAtIndexPath:self.curSelIndexPath];
        newCell.selectButton.selected = YES;
        oldCell.selectButton.selected = NO;
        self.curSelIndexPath = indexPath;
        _sendButton.enabled = YES;
        _sendButton.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

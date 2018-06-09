//
//  SJGiveGiftViewController.m
//  CaiShiJie
//
//  Created by user on 16/11/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJGiveGiftViewController.h"
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
#import "SJGiveGfitSuccessView.h"

@interface SJGiveGiftViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    SJNetManager *netManager;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *giftDataArray;
@property (nonatomic, strong) NSIndexPath *curSelIndexPath;
/**
 用户余额
 */
@property (nonatomic, copy) NSString *goldCount;

@end

@implementation SJGiveGiftViewController

- (NSMutableArray *)giftDataArray {
    if (_giftDataArray == nil) {
        _giftDataArray = [NSMutableArray array];
    }
    return _giftDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupChildSubviews];
    // 加载礼物列表
    [self loadGiftListData];
    // 获取用户金币数
    [self loadUserGoldCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"赠送" style:UIBarButtonItemStylePlain target:self action:@selector(sendGift)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        }
    } failure:^(NSError *error) {
        //SJLog(@"%@", error);
    }];
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
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
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
        
    }];
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
    return CGSizeMake((SJScreenW - 10) /4, (SJScreenW - 10) /4 + 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SJGivePresentCell *newCell = (SJGivePresentCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.curSelIndexPath == nil) {
        newCell.selectButton.selected = YES;
        self.curSelIndexPath = indexPath;
    } else if (indexPath == self.curSelIndexPath) {
        newCell.selectButton.selected = NO;
        self.curSelIndexPath = nil;
    } else {
        SJGivePresentCell *oldCell = (SJGivePresentCell *)[collectionView cellForItemAtIndexPath:self.curSelIndexPath];
        newCell.selectButton.selected = YES;
        oldCell.selectButton.selected = NO;
        self.curSelIndexPath = indexPath;
    }
}

- (void)sendGift {
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
    if (self.curSelIndexPath == nil) {
        UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请选择您要赠送的礼物！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
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

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

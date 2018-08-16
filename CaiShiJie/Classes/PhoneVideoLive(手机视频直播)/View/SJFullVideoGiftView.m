//
//  SJFullVideoGiftView.m
//  CaiShiJie
//
//  Created by user on 18/8/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJFullVideoGiftView.h"
#import "SJFullVideoGiftCell.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "SJGiftModel.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "SJGiftPayView.h"
#import "SJGoldPay.h"
#import "SJNetManager.h"

@interface SJFullVideoGiftView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *voucherButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 用户余额
 */
@property (nonatomic, copy) NSString *goldCount;

@end

@implementation SJFullVideoGiftView

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" withAlpha:0.7];
        [self setupChildViews];
        // 加载礼物列表
        [self loadGiftListData];
        // 获取用户金币数
        [self loadUserGoldCount];
    }
    return self;
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

- (void)setupChildViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"SJFullVideoGiftCell" bundle:nil] forCellWithReuseIdentifier:@"SJFullVideoGiftCell"];
    [self addSubview:_collectionView];
    
    _voucherButton = [[UIButton alloc] init];
    [_voucherButton setAttributedTitle:[self getAttributedStringTitleWithString:@"去充值：0金币>>"] forState:UIControlStateNormal];
    _voucherButton.tag = -1;
    [_voucherButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_voucherButton];
    
    _sendButton = [[UIButton alloc] init];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_sendButton setBackgroundColor:[UIColor colorWithHexString:@"#a0a0a0" withAlpha:1]];
    _sendButton.layer.cornerRadius = 5;
    _sendButton.layer.masksToBounds = YES;
    _sendButton.tag = -2;
    _sendButton.enabled = NO;
    [_sendButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(69);
        make.right.equalTo(weakSelf.mas_right).offset(-15);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-10);
    }];
    
    [_voucherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(17);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-5);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.sendButton.mas_top).offset(-10);
    }];
}

#pragma mark - 获取礼物列表信息
- (void)loadGiftListData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/gift/index",HOST];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJGiftModel objectArrayWithKeyValuesArray:respose[@"data"][@"gift"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.collectionView reloadData];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case -1:
        {
            SJLog(@"去充值");
            if (self.clickBuyGoldButtonBlock) {
                self.clickBuyGoldButtonBlock();
            }
        }
            break;
        case -2:
        {
            SJLog(@"发送");
            if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
                // 未登录
                if (self.needSkipBlock) {
                    self.needSkipBlock();
                }
                return;
            }
            if ([[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] || [[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
                // 已登录，不能送礼
                UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"暂不支持送礼，敬请期待！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alerview show];
                return;
            }
            SJGiftModel *model = [self.dataArray objectAtIndex:self.selectedIndexPath.row];
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
    
    [[SJNetManager sharedNetManager] goldToPayWithParam:goldPay success:^(NSDictionary *dict) {
        if ([dict[@"status"] isEqualToString:@"10"]) {
            SJLog(@"赠送成功");
            [self loadUserGoldCount];
        } else {
            SJLog(@"赠送失败");
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJFullVideoGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJFullVideoGiftCell" forIndexPath:indexPath];
    if ([self.selectedIndexPath isEqual:indexPath]) {
        [cell setSelectIconHidden:NO];
    } else {
        [cell setSelectIconHidden:YES];
    }
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(94, self.collectionView.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SJFullVideoGiftCell *newCell = (SJFullVideoGiftCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.selectedIndexPath == nil) {
        [newCell setSelectIconHidden:NO];
        self.selectedIndexPath = indexPath;
        self.sendButton.enabled = YES;
        self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    } else if ([self.selectedIndexPath isEqual:indexPath]) {
        [newCell setSelectIconHidden:YES];
        self.selectedIndexPath = nil;
        self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#a0a0a0" withAlpha:1];
        self.sendButton.enabled = NO;
    } else {
        SJFullVideoGiftCell *oldCell = (SJFullVideoGiftCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        [oldCell setSelectIconHidden:YES];
        [newCell setSelectIconHidden:NO];
        self.selectedIndexPath = indexPath;
        self.sendButton.enabled = YES;
        self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

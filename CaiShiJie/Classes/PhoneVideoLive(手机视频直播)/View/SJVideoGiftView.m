//
//  SJVideoGiftView.m
//  CaiShiJie
//
//  Created by user on 18/7/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoGiftView.h"
#import "SJVideoGiftItem.h"
#import "SJhttptool.h"
#import "SJGiftModel.h"
#import "MJExtension.h"
#import "SJLoginViewController.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import "SJGiftPayView.h"
#import "SJGoldPay.h"
#import "SJNetManager.h"
#import "SJBuyGoldCoinViewController.h"

#define GIFTBACKGROUNDVIEWHEIGHT 250

@interface SJVideoGiftView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *voucherButton;
@property (nonatomic, strong) SJVideoGiftItem *selectedItem;
/**
 用户余额
 */
@property (nonatomic, copy) NSString *goldCount;

@end

@implementation SJVideoGiftView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" withAlpha:0.7];
        [self setupChildViews];
        [self initLayoutSubviews];
        // 加载礼物列表
        [self loadGiftListData];
        // 获取用户金币数
        [self loadUserGoldCount];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
    }
    return self;
}

- (void)setupChildViews {
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor clearColor];
    [self addSubview:_topView];
    
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    [self.topView addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [_pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    [self.topView addSubview:_pageControl];
    
    _voucherButton = [[UIButton alloc] init];
    [_voucherButton setAttributedTitle:[self getAttributedStringTitleWithString:@"去充值：0金币>>"] forState:UIControlStateNormal];
    _voucherButton.tag = -1;
    [_voucherButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:_voucherButton];
    
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
    [self.bottomView addSubview:_sendButton];
    
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

- (void)initLayoutSubviews {
    _bottomView.frame = CGRectMake(0, GIFTBACKGROUNDVIEWHEIGHT - 35, SJScreenW, 35);
    _topView.frame = CGRectMake(0, 0, SJScreenW, GIFTBACKGROUNDVIEWHEIGHT - 35);
    _pageControl.frame = CGRectMake(0, GIFTBACKGROUNDVIEWHEIGHT - 35 - 8 -  3, SJScreenW, 8);
    _scrollView.frame = CGRectMake(0, 0, SJScreenW, GIFTBACKGROUNDVIEWHEIGHT- 35 - 8 - 3);
    
    WS(weakSelf);
    [_voucherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.bottomView.mas_left).offset(17);
        make.centerY.mas_equalTo(weakSelf.bottomView);
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(69);
        make.right.equalTo(weakSelf.bottomView.mas_right).offset(-10);
        make.centerY.mas_equalTo(weakSelf.bottomView);
    }];
}

#pragma mark - 获取礼物列表信息
- (void)loadGiftListData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/gift/index",HOST];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJGiftModel objectArrayWithKeyValuesArray:respose[@"data"][@"gift"]];
            if (tmpArray.count) {
                [self setItems:tmpArray];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)loginSuccess {
    [self loadUserGoldCount];
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
        //SJLog(@"%@", error);
    }];
}

- (void)setItems:(NSArray *)items {
    self.pageControl.numberOfPages = items.count / 8 + 1;
    self.scrollView.contentSize = CGSizeMake(SJScreenW * (items.count / 8 + 1), self.scrollView.height);

    float w = SJScreenW / 4;
    float h = self.scrollView.height / 2;
    
    float x = 0, y = 0;
    int i = 0, page = 0;
    for (SJGiftModel *model in items) {
        SJVideoGiftItem *item = [[SJVideoGiftItem alloc] init];
        item.model = model;
        [self.scrollView addSubview:item];
        item.frame = CGRectMake(x, y, w, h);
        item.tag = i;
        [item addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];

        i++;
        page = i % 8 == 0 ? page + 1 : page;
        x = (i % 4 ? x + w : page * SJScreenW);
        y = (i % 8 < 4 ? 0 : h);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / SJScreenW;
    [self.pageControl setCurrentPage:page];
}

#pragma Event Response
- (void)pageControlClicked:(UIPageControl *)pageControl {
    [self.scrollView scrollRectToVisible:CGRectMake(pageControl.currentPage * SJScreenW, 0, SJScreenW, self.scrollView.height) animated:YES];
}

- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case -1:
        {
            // 去充值
            SJLog(@"去充值");
            if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
                // 未登录
                SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
                UIViewController *vc = [self getCurrentViewController];
                if (vc) {
                    [vc.navigationController pushViewController:loginVC animated:YES];
                }
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
            UIViewController *vc = [self getCurrentViewController];
            if (vc) {
                [vc.navigationController pushViewController:buyGoldCoinVC animated:YES];
            }
        }
            break;
        case -2:
        {
            // 发送
            SJLog(@"发送");
            if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
                // 未登录
                SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
                UIViewController *vc = [self getCurrentViewController];
                if (vc) {
                    [vc.navigationController pushViewController:loginVC animated:YES];
                }
                return;
            }
            if ([[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] || [[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
                // 已登录，不能送礼
                UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"暂不支持送礼，敬请期待！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alerview show];
                return;
            }
            SJGiftModel *model = self.selectedItem.model;
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

/**
 获取当前View的控制器对象

 @return 控制器
 */
- (UIViewController *)getCurrentViewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)didSelectedItem:(SJVideoGiftItem *)sender {
    //SJLog(@"%i", sender.tag);
    if (self.selectedItem == nil) {
        // 第一次选择
        [sender selectedItem:YES];
        self.selectedItem = sender;
        self.sendButton.enabled = YES;
        self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    } else if ([self.selectedItem isEqual:sender]) {
        // 取消选择
        [sender selectedItem:NO];
        self.selectedItem = nil;
        self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#a0a0a0" withAlpha:1];
        self.sendButton.enabled = NO;
    } else {
        // 选择不同的
        [sender selectedItem:YES];
        [self.selectedItem selectedItem:NO];
        self.selectedItem = sender;
        self.sendButton.enabled = YES;
        self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

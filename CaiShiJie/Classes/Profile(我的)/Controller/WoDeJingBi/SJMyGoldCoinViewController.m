//
//  SJMyGoldCoinViewController.m
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJMyGoldCoinViewController.h"
#import "SJBuyGoldCoinViewController.h"

@interface SJMyGoldCoinViewController ()
// 我的金币数
@property (weak, nonatomic) IBOutlet UILabel *myGoldCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *chargeMoneyBtn;

@end

@implementation SJMyGoldCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chargeMoneyBtn.hidden = NO;
    self.myGoldCoinLabel.text = self.goldCoinStr;
    [self.myGoldCoinLabel sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

// 点击充值按钮时调用
- (IBAction)chargeMoneyBtnPressed:(id)sender
{
    SJBuyGoldCoinViewController *buyGoldCoinVC = [[SJBuyGoldCoinViewController alloc] init];
    buyGoldCoinVC.navigationItem.title = @"充值金币";
    [self.navigationController pushViewController:buyGoldCoinVC animated:YES];
}

@end

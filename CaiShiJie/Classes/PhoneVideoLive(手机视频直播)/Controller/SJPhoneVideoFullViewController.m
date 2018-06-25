//
//  SJPhoneVideoFullViewController.m
//  CaiShiJie
//
//  Created by user on 18/8/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPhoneVideoFullViewController.h"
#import "SJFullVideoAboveView.h"
#import "SJUserVideoTopView.h"
#import "SJUserInfo.h"
#import "SJFullVideoGiftView.h"
#import "SJUserInfoView.h"

@interface SJPhoneVideoFullViewController ()

@end

@implementation SJPhoneVideoFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupChildViews];
}

- (void)setupChildViews {
    WS(weakSelf);
    _fullVideoAboveView = [[SJFullVideoAboveView alloc] init];
    _fullVideoAboveView.model = _model;
    [self.view addSubview:_fullVideoAboveView];
    _fullVideoAboveView.clickExitButtonEventBlock = ^() {
        // 点击了返回和退出全屏按钮
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            if (weakSelf.dismissViewControllerBlock) {
                weakSelf.dismissViewControllerBlock();
            }
        }];
    };
    _fullVideoAboveView.needPushBlock = ^() {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(skipToLoginViewController)]) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                if (weakSelf.dismissViewControllerBlock) {
                    weakSelf.dismissViewControllerBlock();
                }
                [weakSelf.delegate skipToLoginViewController];
            }];
        }
    };
    _fullVideoAboveView.fullVideoGiftView.clickBuyGoldButtonBlock = ^() {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(skipToBuyGoldViewController)]) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                if (weakSelf.dismissViewControllerBlock) {
                    weakSelf.dismissViewControllerBlock();
                }
                [weakSelf.delegate skipToBuyGoldViewController];
            }];
        }
    };
    _fullVideoAboveView.fullVideoGiftView.needSkipBlock = ^() {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(skipToLoginViewController)]) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                if (weakSelf.dismissViewControllerBlock) {
                    weakSelf.dismissViewControllerBlock();
                }
                [weakSelf.delegate skipToLoginViewController];
            }];
        }
    };
    _fullVideoAboveView.userVideoTopView.clickUserAttentionButtonBlock = ^(UIButton *button){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(fullVideoAboveViewAttentionButtonClicked:)]) {
            // 横屏点击关注时
            if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
                // 如何已经登录，则直接执行代理方法
                [weakSelf.delegate fullVideoAboveViewAttentionButtonClicked:button];
                return ;
            }
            // 如果没有登录，需要先回到竖屏，再执行代理方法
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                if (weakSelf.dismissViewControllerBlock) {
                    weakSelf.dismissViewControllerBlock();
                }
                [weakSelf.delegate fullVideoAboveViewAttentionButtonClicked:button];
            }];
        }
    };
    _fullVideoAboveView.userInfoViewMoreButtonBlock = ^(UIButton *button) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoViewMoreButtonPressed:)]) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                if (weakSelf.dismissViewControllerBlock) {
                    weakSelf.dismissViewControllerBlock();
                }
                [weakSelf.delegate userInfoViewMoreButtonPressed:button];
            }];
        }
    };
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.fullVideoAboveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
}

- (void)setPresentBgView:(UIView *)presentBgView {
    _presentBgView = presentBgView;
    
    [self.view addSubview:_presentBgView];
    [_presentBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(110);
        make.centerY.equalTo(self.view.mas_centerY).offset(0);
    }];
}

#pragma mark - 横屏代码
- (BOOL)shouldAutorotate {
    return YES;
} //当前viewcontroller是否支持转屏

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
} //当前viewcontroller支持哪些转屏方向

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

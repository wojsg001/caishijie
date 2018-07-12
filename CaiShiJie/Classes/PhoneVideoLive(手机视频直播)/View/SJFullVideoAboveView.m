//
//  SJFullVideoAboveView.m
//  CaiShiJie
//
//  Created by user on 18/8/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJFullVideoAboveView.h"
#import "SJUserVideoTopView.h"
#import "TLChatBoxViewController.h"
#import "SJUserInfoView.h"
#import "SJFullVideoGiftView.h"
#import "SJDanMuView.h"
#import "SJVideoTeacherInfoModel.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "RegexKitLite.h"
#import "SJFaceHandler.h"
#import "SJUserInfo.h"
#import "SJOpinionView.h"

#define OpinionViewHeight 189

@interface SJFullVideoAboveView ()<TLChatBoxViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *barrageButton;// 弹幕
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *giftButton;
@property (nonatomic, strong) UIButton *fullButton;
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) UITapGestureRecognizer *singleFingerOne;
@property (nonatomic, strong) SJDanMuView *danmuView;
@property (nonatomic, strong) SJOpinionView *fullOpinionView;
@property (nonatomic, strong) SJUserInfoView *userInfoView;
@property (nonatomic, strong) NSArray *computerFaceArray;

@end

@implementation SJFullVideoAboveView

#pragma makr - 懒加载
- (SJOpinionView *)fullOpinionView {
    if (!_fullOpinionView) {
        _fullOpinionView = [[SJOpinionView alloc] initWithFrame:CGRectMake(0, SJScreenW, SJScreenH, OpinionViewHeight)];
        _fullOpinionView.isFullScreen = YES;
    }
    return _fullOpinionView;
}

- (TLChatBoxViewController *)chatBoxVC {
    if (!_chatBoxVC) {
        _chatBoxVC = [[TLChatBoxViewController alloc] init];
        [_chatBoxVC setUpChatBoxMoreButtonHidden:YES];
        [_chatBoxVC setLandscapeChatBoxFrame];
    }
    return _chatBoxVC;
}

- (SJUserInfoView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[SJUserInfoView alloc] initWithFrame:CGRectMake((SJScreenW - 280)/2, -250, 280, 250)];
        WS(weakSelf);
        _userInfoView.clickDeleteButtonBlock = ^() {
            // 点击删除按钮
            [weakSelf.userInfoView removeFromSuperview];
            weakSelf.userInfoView = nil;
        };
        _userInfoView.clickMoreButtonBlock = ^(UIButton *button) {
            if (weakSelf.userInfoViewMoreButtonBlock) {
                weakSelf.userInfoViewMoreButtonBlock(button);
            }
        };
    }
    return _userInfoView;
}

- (SJFullVideoGiftView *)fullVideoGiftView {
    if (!_fullVideoGiftView) {
        _fullVideoGiftView = [[SJFullVideoGiftView alloc] initWithFrame:CGRectMake(0, SJScreenW, SJScreenH, 150)];
    }
    return _fullVideoGiftView;
}

- (SJDanMuView *)danmuView {
    if (!_danmuView) {
        _danmuView = [[SJDanMuView alloc] init];
    }
    return _danmuView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        // 表情数组
        self.computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews {
    WS(weakSelf);
    _singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnClick:)];
    _singleFingerOne.numberOfTouchesRequired = 1;
    _singleFingerOne.numberOfTapsRequired = 1;
    _singleFingerOne.delegate = self;
    [self addGestureRecognizer:_singleFingerOne];
    
    _userVideoTopView = [[SJUserVideoTopView alloc] init];
    _userVideoTopView.clickUserHeadImageBlock = ^() {
        // 点击了用户头像
        [weakSelf addSubview:weakSelf.userInfoView];
        weakSelf.userInfoView.model = weakSelf.model;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.userInfoView.transform = CGAffineTransformMakeTranslation(0, 250 + (SJScreenH-250)/2);
        }];
    };
    [self addSubview:_userVideoTopView];
    
    _backButton = [[UIButton alloc] init];
    [_backButton setImage:[UIImage imageNamed:@"live_off_icon"] forState:UIControlStateNormal];
    _backButton.tag = 101;
    [_backButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _chatButton = [[UIButton alloc] init];
    [_chatButton setImage:[UIImage imageNamed:@"live_down_icon1"] forState:UIControlStateNormal];
    _chatButton.tag = 102;
    [_chatButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chatButton];
    [_chatButton setHidden:YES];
    
    _barrageButton = [[UIButton alloc] init];
    [_barrageButton setImage:[UIImage imageNamed:@"tan_icon"] forState:UIControlStateNormal];
    [_barrageButton setImage:[UIImage imageNamed:@"tan_icon_h"] forState:UIControlStateSelected];
    _barrageButton.selected = NO;
    _barrageButton.tag = 103;
    [_barrageButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_barrageButton];
    [_barrageButton setHidden:YES];
    
    _recordButton = [[UIButton alloc] init];
    [_recordButton setImage:[UIImage imageNamed:@"live_down_icon2"] forState:UIControlStateNormal];
    _recordButton.tag = 104;
    [_recordButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recordButton];
    [_recordButton setHidden:YES];
    
    _giftButton = [[UIButton alloc] init];
    [_giftButton setImage:[UIImage imageNamed:@"live_down_icon3"] forState:UIControlStateNormal];
    _giftButton.tag = 105;
    [_giftButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_giftButton];
    [_giftButton setHidden:YES];
    
    _fullButton = [[UIButton alloc] init];
    [_fullButton setImage:[UIImage imageNamed:@"live_suo"] forState:UIControlStateNormal];
    _fullButton.tag = 106;
    [_fullButton addTarget:self action:@selector(clickButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_fullButton];
    [_fullButton setHidden:YES];
    
    [self addSubview:self.chatBoxVC.view];
    [self.chatBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.mas_left).offset(0);
        make.right.equalTo(weakSelf.mas_right).offset(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
    [self addSubview:self.fullVideoGiftView];
    [self addSubview:self.fullOpinionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    [_userVideoTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_top).offset(10);
        make.left.equalTo(weakSelf.mas_left).offset(10);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(130);
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    
    [_fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
    }];
    
    [_giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.fullButton.mas_top).offset(-15);
        make.centerX.mas_equalTo(weakSelf.fullButton);
    }];
    
    [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.giftButton.mas_top).offset(-15);
        make.centerX.mas_equalTo(weakSelf.fullButton);
    }];
    
    [_barrageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.recordButton.mas_top).offset(-15);
        make.centerX.mas_equalTo(weakSelf.fullButton);
    }];
    
    [_chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
    
    _userVideoTopView.model = model;
    _fullVideoGiftView.targetid = model.user_id;
}

- (void)clickButtonEvent:(UIButton *)sender {
    WS(weakSelf);
    switch (sender.tag) {
        case 101: {
            // 返回
            if (self.clickExitButtonEventBlock) {
                self.clickExitButtonEventBlock();
            }
        }
            break;
        case 102: {
            // 发消息
            [self.chatBoxVC setDelegate:self];
            [self.chatBoxVC setUpChatBoxTextViewBecomeFirstResponder];
        }
            break;
        case 103: {
            // 弹幕开关
            sender.selected = !sender.selected;
            if (sender.selected) {
                // 打开弹幕
                [self addSubview:self.danmuView];
                [self sendSubviewToBack:self.danmuView];
                [_danmuView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(weakSelf.barrageButton.mas_bottom).offset(0);
                    make.bottom.equalTo(weakSelf.fullButton.mas_top).offset(0);
                    make.left.equalTo(weakSelf.chatButton.mas_right).offset(5);
                    make.right.equalTo(weakSelf.fullButton.mas_left).offset(-5);
                }];
            } else {
                // 关闭弹幕
                [self.danmuView removeFromSuperview];
                self.danmuView = nil;
            }
        }
            break;
        case 104: {
            // 观点
            [UIView animateWithDuration:0.5 animations:^{
                self.fullOpinionView.transform = CGAffineTransformMakeTranslation(0, -OpinionViewHeight);
            }];
        }
            break;
        case 105: {
            // 礼物
            [UIView animateWithDuration:0.5 animations:^{
                self.fullVideoGiftView.transform = CGAffineTransformMakeTranslation(0, -150);
            }];
        }
            break;
        case 106: {
            // 退出全屏
            if (self.clickExitButtonEventBlock) {
                self.clickExitButtonEventBlock();
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 点击事件
- (void)tapOnClick:(UITapGestureRecognizer *)tap {
    [self.chatBoxVC resignFirstResponder];
    [self.chatBoxVC setDelegate:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.fullVideoGiftView.transform = CGAffineTransformIdentity;
        self.fullOpinionView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

#pragma mark - TLChatBoxViewControllerDelegate
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height andDuration:(CGFloat)duration
{
    WS(weakSelf);
    if (height <= kTabbarHeight) {
        [self.chatBoxVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.mas_bottom).offset(0);
            make.left.equalTo(weakSelf.mas_left).offset(0);
            make.right.equalTo(weakSelf.mas_right).offset(0);
            make.height.mas_equalTo(kTabbarHeight);
        }];
    } else {
        [self.chatBoxVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.mas_bottom).offset(0);
            make.left.equalTo(weakSelf.mas_left).offset(0);
            make.right.equalTo(weakSelf.mas_right).offset(0);
            make.height.mas_equalTo(height);
        }];
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        if (self.needPushBlock) {
            self.needPushBlock();
        }
        return;
    }
    [self sendMessage:message];
    [self.chatBoxVC resignFirstResponder];
}

- (void)sendMessage:(NSString *)message {
    __block NSString *text = message;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!text.length) {
        return;
    }
    
    [text enumerateStringsMatchedByRegex:@"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount > 0) {
            NSString *tmpString = capturedStrings[0];
            if ([self.computerFaceArray containsObject:tmpString]) {
                NSInteger index = [self.computerFaceArray indexOfObject:tmpString];
                NSString *string = tmpString;
                string = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSString *faceString = [NSString stringWithFormat:@"<img src=\"http://common.csjimg.com/emot/qq/%ld.gif\" title=\"%@\">", index + 1, string];
                text = [text stringByReplacingOccurrencesOfString:tmpString withString:faceString];
            }
        }
    }];
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/sendinteraction",HOST];
    NSDictionary *params = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":self.model.user_id,@"content":text};
    [SJhttptool POST:urlStr paramers:params success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            SJLog(@"发送成功");
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[self class]]) {
        return YES;
    }
    return NO;
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

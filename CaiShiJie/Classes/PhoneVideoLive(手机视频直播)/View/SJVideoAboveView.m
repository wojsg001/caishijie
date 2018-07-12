//
//  SJVideoAboveView.m
//  CaiShiJie
//
//  Created by user on 18/7/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoAboveView.h"
#import "SJUserVideoTopView.h"
#import "SJUserVideoBottomToolBar.h"
#import "TLChatBoxViewController.h"
#import "SJVideoInteractiveCell.h"
#import "SJVideoGiftView.h"
#import "SJOpinionView.h"
#import "SJUserInfoView.h"
#import "SJVideoInteractiveModel.h"
#import "SDAutoLayout.h"
#import "MJExtension.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"
#import "RegexKitLite.h"
#import "SJFaceHandler.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "SJVideoTeacherInfoModel.h"
#import "SJAnimOperationManager.h"
#import "SJAnimOperation.h"
#import "SJPresentFlower.h"
#import "SJGiftModel.h"

#define BottomToolBarHeight 57
#define GiftViewHeight 250
#define OpinionViewHeight 315

@interface SJVideoAboveView ()<TLChatBoxViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) SJUserVideoBottomToolBar *userVideoBottomToolBar;
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJVideoGiftView *giftView;
@property (nonatomic, strong) SJOpinionView *opinionView;
@property (nonatomic, strong) SJUserInfoView *userInfoView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *computerFaceArray;

@end

@implementation SJVideoAboveView

#pragma makr - 懒加载
- (SJOpinionView *)opinionView {
    if (!_opinionView) {
        _opinionView = [[SJOpinionView alloc] initWithFrame:CGRectMake(0, SJScreenH, SJScreenW, OpinionViewHeight)];
        _opinionView.isFullScreen = NO;
    }
    return _opinionView;
}

- (TLChatBoxViewController *)chatBoxVC {
    if (!_chatBoxVC) {
        _chatBoxVC = [[TLChatBoxViewController alloc] init];
        [_chatBoxVC setUpChatBoxMoreButtonHidden:YES];
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

- (SJVideoGiftView *)giftView {
    if (!_giftView) {
        _giftView= [[SJVideoGiftView alloc] initWithFrame:CGRectMake(0, SJScreenH, SJScreenW, GiftViewHeight)];
    }
    return _giftView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        // 表情数组
        self.computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
        [self setupChildViews];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInteract:) name:KNotificationAddInteract object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLunxunInteract:) name:KNotificationAddLunXUnInteract object:nil];
}

- (void)setupChildViews {
    WS(weakSelf);
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor clearColor];
    [self addSubview:_topView];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnClick:)];
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.numberOfTapsRequired = 1;
    [self.topView addGestureRecognizer:singleFingerOne];
    
    _userVideoTopView = [[SJUserVideoTopView alloc] init];
    _userVideoTopView.clickUserHeadImageBlock = ^() {
        // 点击了用户头像
        [weakSelf addSubview:weakSelf.userInfoView];
        weakSelf.userInfoView.model = weakSelf.model;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.userInfoView.transform = CGAffineTransformMakeTranslation(0, 250 + (SJScreenH-250)/2);
        }];
    };
    [self.topView addSubview:_userVideoTopView];
    // 返回
    _backButton = [[UIButton alloc] init];
    [_backButton setImage:[UIImage imageNamed:@"live_off_icon"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_backButton];
    // 底部工具条
    _userVideoBottomToolBar = [[SJUserVideoBottomToolBar alloc] init];
    _userVideoBottomToolBar.clickButtonEventBlock = ^(NSInteger index) {
        switch (index) {
            case 101:
            {
                // 输入文字
                [weakSelf.chatBoxVC setDelegate:weakSelf];
                [weakSelf.chatBoxVC setUpChatBoxTextViewBecomeFirstResponder];
            }
                break;
            case 102:
            {
                // 观点
                [UIView animateWithDuration:0.5 animations:^{
                    weakSelf.opinionView.transform = CGAffineTransformMakeTranslation(0, -OpinionViewHeight);
                } completion:nil];
            }
                break;
            case 103:
            {
                // 礼物
                [UIView animateWithDuration:0.5 animations:^{
                    weakSelf.giftView.transform = CGAffineTransformMakeTranslation(0, -GiftViewHeight);
                    weakSelf.userVideoBottomToolBar.transform = CGAffineTransformMakeTranslation(0, BottomToolBarHeight);
                } completion:nil];
            }
                break;
            case 104:
            {
                // 全屏
                if (weakSelf.fullButtonClickBlock) {
                    weakSelf.fullButtonClickBlock();
                }
            }
                break;
                
            default:
                break;
        }
    };
    [self addSubview:_userVideoBottomToolBar];
    [self addSubview:self.opinionView];
    [self addSubview:self.giftView];
    [self addSubview:self.chatBoxVC.view];
    [self.chatBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.mas_left).offset(0);
        make.right.equalTo(weakSelf.mas_right).offset(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.topView addSubview:_tableView];
    
    _presentBgView = [[UIView alloc] init];
    _presentBgView.backgroundColor = [UIColor clearColor];
    _presentBgView.userInteractionEnabled = NO;
    [self.topView addSubview:_presentBgView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    WS(weakSelf);
    [_userVideoBottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(BottomToolBarHeight);
        make.left.bottom.right.mas_equalTo(weakSelf);
    }];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.userVideoBottomToolBar.mas_top).offset(0);
    }];
    
    [_userVideoTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.topView.mas_top).offset(25);
        make.left.equalTo(weakSelf.topView.mas_left).offset(10);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(135);
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.topView.mas_top).offset(25);
        make.right.equalTo(weakSelf.topView.mas_right).offset(-10);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.height.mas_equalTo(125);
        make.width.mas_equalTo(250);
    }];
    
    [_presentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(weakSelf.tableView.mas_top).offset(-69);
        make.height.mas_equalTo(110);
    }];
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
    
    self.userVideoTopView.model = model;
    self.giftView.targetid = model.user_id;
}

- (void)addPresentBgView {
    [self.topView addSubview:_presentBgView];
    [_presentBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(self.tableView.mas_top).offset(-69);
        make.height.mas_equalTo(110);
    }];
}

#pragma mark - 点击事件
- (void)clickBackButton:(UIButton *)sender {
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock();
    }
}

- (void)tapOnClick:(UITapGestureRecognizer *)tap {
    [self.chatBoxVC resignFirstResponder];
    [self.chatBoxVC setDelegate:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.giftView.transform = CGAffineTransformIdentity;
        self.userVideoBottomToolBar.transform = CGAffineTransformIdentity;
        self.opinionView.transform = CGAffineTransformIdentity;
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
        
        [UIView animateWithDuration:duration animations:^{
            weakSelf.topView.transform = CGAffineTransformIdentity;
        } completion:nil];
        
    } else {
        [self.chatBoxVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.mas_bottom).offset(0);
            make.left.equalTo(weakSelf.mas_left).offset(0);
            make.right.equalTo(weakSelf.mas_right).offset(0);
            make.height.mas_equalTo(height);
        }];
        
        [UIView animateWithDuration:duration animations:^{
            weakSelf.topView.transform = CGAffineTransformMakeTranslation(0, -(height - BottomToolBarHeight));
        } completion:nil];
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        UIResponder *responder = [self.superview nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)responder;
            [vc.navigationController pushViewController:loginVC animated:YES];
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
                NSString *faceString = [NSString stringWithFormat:@"<img src=\"http://common.csjimg.com/emot/qq/%ld.gif\" title=\"%@\">", (long)index + 1, string];
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

#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoInteractiveCell *cell = [SJVideoInteractiveCell cellWithTableView:tableView];
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoInteractiveModel *model = self.dataArray[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SJVideoInteractiveCell class] contentViewWidth:250];
}

#pragma mark - 接收添加互动的通知
- (void)addInteract:(NSNotification *)n {
    NSDictionary *dict = n.object;
    SJLog(@"%@", dict);
    SJVideoInteractiveModel *model = [SJVideoInteractiveModel objectWithKeyValues:dict];
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    
    [self tableViewScrollToBottom];
    // 添加礼物动画
    [self addGiftAnimate:model];
}

#pragma mark - 接收添加轮询互动的通知
- (void)addLunxunInteract:(NSNotification *)n{
    NSArray *tmpArray = n.object;
    NSArray *modelArray = [SJVideoInteractiveModel objectArrayWithKeyValuesArray:tmpArray];
    [self.dataArray addObjectsFromArray:modelArray];
    [self.tableView reloadData];
    
    [self tableViewScrollToBottom];
    // 添加礼物动画
    for (SJVideoInteractiveModel *model in modelArray) {
        [self addGiftAnimate:model];
    }
}

- (void)addGiftAnimate:(SJVideoInteractiveModel *)model {
    if (![model.type isEqualToString:@"1"]) {
        return;
    }
    
    SJGiftModel *giftModel = [[SJGiftModel alloc] init];
    giftModel.head_img = model.model.head_img;
    giftModel.nickname = model.model.nickname;
    giftModel.gift_name = model.model.item_name;
    giftModel.img = model.model.item_img;
    giftModel.gift_id = model.model.item_id;
    giftModel.user_id = model.user_id;
    giftModel.giftCount = [model.model.item_count integerValue];
    SJAnimOperationManager *manager = [SJAnimOperationManager sharedManager];
    manager.parentView = self.presentBgView;
    [manager animWithUserID:[NSString stringWithFormat:@"%@-%@", giftModel.user_id, giftModel.gift_id] model:giftModel finishedBlock:^(BOOL result) {
        
    }];
}

- (void)tableViewScrollToBottom {
    if (self.dataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat y = scrollView.contentOffset.y;
        if ((scrollView.contentSize.height - self.tableView.frame.size.height - y) < 1.0) {
            // tableview滚动到了底部
            if (self.dataArray.count > 20) {
                NSRange range = NSMakeRange(0, self.dataArray.count - 20);
                [self.dataArray removeObjectsInRange:range];
                [self.tableView reloadData];
            }
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

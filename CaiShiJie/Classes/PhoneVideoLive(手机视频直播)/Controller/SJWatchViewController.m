//
//  SJWatchViewController.m
//  CaiShiJie
//
//  Created by user on 18/7/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJWatchViewController.h"
#import "SJPhoneVideoFullViewController.h"
#import "SJVideoAboveView.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "SJhttptool.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import "SJVideoTeacherInfoModel.h"
#import "MJExtension.h"
#import "SJUserVideoTopView.h"
#import "SJLoginViewController.h"
#import "SJProgressHUD.h"
#import "SRWebSocket.h"
#import "SJhttptool.h"
#import "SJUserInfoView.h"
#import "SJPersonalArticleViewController.h"
#import "SJHisReferenceViewController.h"
#import "SJOldLiveViewController.h"
#import "SJBuyGoldCoinViewController.h"
#import "SJFullVideoAboveView.h"

@interface SJWatchViewController ()<PLPlayerDelegate, SJPhoneVideoFullViewControllerDelegate, SRWebSocketDelegate>
{
    SRWebSocket *_webSocket;
    BOOL _alreadyCreatPLPlayer;
}
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) SJVideoAboveView *videoAboveView;
@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) SJVideoTeacherInfoModel *teacherInfoModel;
@property (nonatomic, strong) NSString *message_max_sn;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SJWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _alreadyCreatPLPlayer = NO;
    // 设置子视图
    [self setupChildViews];
    // 加载直播用户信息
    [self loadLiveData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)loginSuccess {
    [self loadLiveData];
}

- (void)loadLiveData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/findvideo", HOST];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.targetid forKey:@"target_id"];
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJToken *instance = [SJToken sharedToken];
        [params setObject:instance.token forKey:@"token"];
        [params setObject:instance.userid forKey:@"user_id"];
        [params setObject:instance.time forKey:@"time"];
    }
    
    [SJProgressHUD showLoadingToView:self.view];
    [SJhttptool GET:urlStr paramers:params success:^(id respose) {
        SJLog(@"%@", respose);
        [SJProgressHUD hideLoadingFromView:self.view];
        if ([respose[@"status"] integerValue]) {
            _teacherInfoModel = [SJVideoTeacherInfoModel objectWithKeyValues:respose[@"data"]];
            _message_max_sn = [NSString stringWithFormat:@"%@", respose[@"data"][@"message_max_sn"]];
            _videoAboveView.model = _teacherInfoModel;
            
            if ([_teacherInfoModel.live_status isEqualToString:@"2"]) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"直播未开始" preferredStyle:UIAlertControllerStyleAlert];
                    __weak typeof(self) weakSelf = self;
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf.navigationController performSelectorOnMainThread:@selector(popViewControllerAnimated:) withObject:@(YES) waitUntilDone:NO];
                    }];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                return ;
            }
            
            [self reconnect];
            if (!_alreadyCreatPLPlayer) {
                _alreadyCreatPLPlayer = YES;
                // 根据URL创建直播流播放器
                [self setupPLPlayerWithURL:[NSURL URLWithString:_teacherInfoModel.video_url]];
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        WS(weakSelf);
        [SJProgressHUD hideLoadingFromView:self.view];
        [SJProgressHUD showNetworkErrorToView:self.view reload:^{
            [SJProgressHUD hideNetworkErrorFromView:weakSelf.view];
            [weakSelf loadLiveData];
        }];
    }];
}

#pragma mark - 重新连接服务器
- (void)reconnect {
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *urlStr = [NSString stringWithFormat:@"ws://%@/ws?u=%@&l=%@&sn=%@", imHost, [SJUserDefaults valueForKey:kUserid], self.targetid, _message_max_sn];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(lunXunRequestData) userInfo:nil repeats:YES];
}
#pragma mark - 轮询请求数据
- (void)lunXunRequestData
{
    NSString *sn = [NSString stringWithFormat:@"%d", [self.message_max_sn intValue] + 1];
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/lp?u=%@&l=%@&sn=%@",imHost,[SJUserDefaults valueForKey:kUserid],self.targetid,sn];
    SJLog(@"%@", urlStr);
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        SJLog(@"%@", respose);
        id value = respose[@"data"];
        if (value == nil) {
            // 关闭定时器
            [_timer invalidate];
            // 重新开始连接socket服务器
            [self reconnect];
            return ;
        }
        self.message_max_sn = respose[@"sn"];
        NSArray *tmpArray = respose[@"data"];
        NSMutableArray *opinionArray = [NSMutableArray array];
        NSMutableArray *interactArray = [NSMutableArray array];
        for (NSDictionary *tmpDict in tmpArray) {
            if ([tmpDict[@"type"] isEqualToString:@"21"]) {
                // 观点
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSMutableDictionary *dictM = [tmpDict mutableCopy];
                [dictM removeObjectForKey:@"data"];
                dictM[@"data"] = jsonStr;
                [opinionArray addObject:dictM];
                // 发出通知添加轮询观点
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddLunXunOpinion object:opinionArray];
            } else if ([tmpDict[@"type"] isEqualToString:@"40"] || [tmpDict[@"type"] isEqualToString:@"1"]) {
                // 互动、送礼
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSMutableDictionary *dictM = [tmpDict mutableCopy];
                [dictM removeObjectForKey:@"data"];
                dictM[@"data"] = jsonStr;
                [interactArray addObject:dictM];
                // 发出通知添加轮询互动
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddLunXUnInteract object:interactArray];
            }
        }
        // 关闭定时器
        [_timer invalidate];
        // 开始连接服务器
        [self reconnect];
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    //NSLog(@"%@",dict);
    self.message_max_sn = dict[@"sn"];
    if ([dict[@"type"] isEqual:@(21)]) {
        // 观点
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictM = [dict mutableCopy];
        [dictM removeObjectForKey:@"data"];
        dictM[@"data"] = jsonStr;
        // 通知添加观点
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddOpinion object:dictM];
    } else if ([dict[@"type"] isEqual:@(40)] || [dict[@"type"] isEqual:@(1)]) {
        // 互动、送礼
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictM = [dict mutableCopy];
        [dictM removeObjectForKey:@"data"];
        dictM[@"data"] = jsonStr;
        // 通知添加互动
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddInteract object:dictM];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    
    _webSocket = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(lunXunRequestData) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}

- (void)setupPLPlayerWithURL:(NSURL *)url {
    /*
     rtmp://pili-live-rtmp.csjvod.com/lives/10412_1472650828_57c6de4ccd1bc
     rtmp://pili-live-rtmp.csjvod.com/lives/livetext
     */
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    [option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
    [option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
    /*
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [option setOptionValue:@(YES) forKey:PLPlayerOptionKeyVideoToolbox];
    } else {
        [option setOptionValue:@(NO) forKey:PLPlayerOptionKeyVideoToolbox];
    }
    */
    self.player = [PLPlayer playerWithURL:url option:option];
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    self.player.backgroundPlayEnable = NO;

    // 从后台进入前台时执行
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlayer) name:UIApplicationWillEnterForegroundNotification object:nil];

    [self setupPlayerView];
    [self startPlayer];
}

- (void)setupPlayerView {
    if (self.player.status == PLPlayerStatusError || self.player.playerView.superview) {
        // 如果播放器状态错误或已添加到父视图返回
        return;
    }
    
    [self.playerView addSubview:self.player.playerView];
    [self.playerView sendSubviewToBack:self.player.playerView];

    if ([_teacherInfoModel.video_type isEqualToString:@"1"]) {
        // pc端推流时
        self.player.playerView.contentMode = UIViewContentModeScaleToFill;
        self.player.playerView.frame = CGRectMake(0, 85, SJScreenW, SJScreenW * 9 / 16);
    } else {
        // 手机端推流时
        self.player.playerView.contentMode = UIViewContentModeScaleAspectFill;
        self.player.playerView.frame = CGRectMake(0, 0, SJScreenW, SJScreenH);
    }
}

- (void)startPlayer {
    [self.player play];
}

#pragma mark - <PLPlayerDelegate>
// 实现 <PLPlayerDelegate> 来控制流状态的变更
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    SJLog(@"%ld", (long)state);
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
    // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
    // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
    // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    // 点播结束后，将收到 PLPlayerStatusCompleted 状态
    // 播放器播放结束或手动停止的状态 PLPlayerStatusStopped 状态
    if (PLPlayerStatusCaching == state) {
        [MBProgressHUD showHUDAddedTo:self.player.playerView animated:YES];
    }
    else {
        [MBProgressHUD hideHUDForView:self.player.playerView animated:YES];
    }
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *reload = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf startPlayer];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.timer invalidate];
            [strongSelf.navigationController performSelectorOnMainThread:@selector(popViewControllerAnimated:) withObject:@(YES) waitUntilDone:NO];
        }];
        [alert addAction:reload];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [MBProgressHUD hideHUDForView:self.player.playerView animated:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)setupChildViews {
    WS(weakSelf);
    self.playerView = [[UIView alloc] init];
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    self.videoAboveView = [[SJVideoAboveView alloc] init];
    [self.view addSubview:self.videoAboveView];
    [self.videoAboveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    self.videoAboveView.userVideoTopView.clickUserAttentionButtonBlock = ^(UIButton *button) {
        [weakSelf attentionCurrentTeacher:button];
    };
    self.videoAboveView.userInfoViewMoreButtonBlock = ^(UIButton *button) {
        [weakSelf userInfoViewMoreButtonClicked:button];
    };
    self.videoAboveView.backButtonClickBlock = ^() {
        // 返回按钮
        [weakSelf.timer invalidate]; // 退出时关闭定时器
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    self.videoAboveView.fullButtonClickBlock = ^() {
        // 全屏按钮
        SJPhoneVideoFullViewController *fullVC = [[SJPhoneVideoFullViewController alloc] init];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        fullVC.delegate = strongSelf;
        fullVC.model = weakSelf.teacherInfoModel;
        [fullVC.view addSubview:weakSelf.player.playerView];
        [fullVC.view sendSubviewToBack:weakSelf.player.playerView];
        weakSelf.player.playerView.frame = CGRectMake(0, 0, SJScreenH, SJScreenW);
        [weakSelf presentViewController:fullVC animated:NO completion:^{
            // 弹出全屏后将礼物动画添加到全屏页面中
            fullVC.presentBgView = weakSelf.videoAboveView.presentBgView;
        }];
        fullVC.dismissViewControllerBlock = ^() {
            // 退出全屏
            [weakSelf.playerView addSubview:weakSelf.player.playerView];
            [weakSelf.playerView sendSubviewToBack:weakSelf.player.playerView];
            if ([weakSelf.teacherInfoModel.video_type isEqualToString:@"1"]) {
                // pc端推流时
                weakSelf.player.playerView.frame = CGRectMake(0, 85, SJScreenW, SJScreenW * 9 / 16);
            } else {
                // 手机端推流时
                weakSelf.player.playerView.frame = CGRectMake(0, 0, SJScreenW, SJScreenH);
            }
            // 退出后将礼物动画重新添加到竖屏页面中
            [weakSelf.videoAboveView addPresentBgView];
        };
    };
}

#pragma mark - 关注
- (void)attentionCurrentTeacher:(UIButton *)button {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }

    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/attention",HOST];
    NSDictionary *params = @{@"userid":instance.userid,@"targetid":self.targetid,@"token":instance.token,@"time":instance.time};
    [SJhttptool POST:urlStr paramers:params success:^(id respose) {
        if ([respose[@"status"] isEqual:@"1"]) {
            button.selected = YES;
            button.userInteractionEnabled = NO;
            [MBProgressHUD showSuccess:@"关注成功!"];
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

/**
 跳转内参、博文、历史

 @param button 点击的按钮
 */
- (void)userInfoViewMoreButtonClicked:(UIButton *)button {
    switch (button.tag) {
        case 101: {
            // 博文
            SJPersonalArticleViewController *personalArticleVC = [[SJPersonalArticleViewController alloc] init];
            personalArticleVC.userid = self.targetid;
            personalArticleVC.title = @"他的博文";
            [self.navigationController pushViewController:personalArticleVC animated:YES];
        }
            break;
        case 102: {
            // 内参
            SJHisReferenceViewController *hisReferenceVC = [[SJHisReferenceViewController alloc] init];
            hisReferenceVC.title = @"他的内参";
            hisReferenceVC.user_id = self.targetid
            ;
            [self.navigationController pushViewController:hisReferenceVC animated:YES];
        }
            break;
        case 103: {
            // 历史直播
            SJOldLiveViewController *oldLiveVC = [[SJOldLiveViewController alloc] init];
            oldLiveVC.title = @"历史直播";
            oldLiveVC.userid = self.targetid;
            [self.navigationController pushViewController:oldLiveVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - SJPhoneVideoFullViewControllerDelegate
- (void)fullVideoAboveViewAttentionButtonClicked:(UIButton *)button {
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        [self attentionCurrentTeacher:button];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self attentionCurrentTeacher:button];
        });
    }
}

- (void)skipToLoginViewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    });
}

- (void)skipToBuyGoldViewController {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 未登录
        [self skipToLoginViewController];
        return;
    }
    if ([[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] || [[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"暂不支持充值，敬请期待！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SJBuyGoldCoinViewController *buyGoldCoinVC = [[SJBuyGoldCoinViewController alloc] init];
        buyGoldCoinVC.navigationItem.title = @"充值金币";
        [self.navigationController pushViewController:buyGoldCoinVC animated:YES];
    });
}

- (void)userInfoViewMoreButtonPressed:(UIButton *)button {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self userInfoViewMoreButtonClicked:button];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
    SJLog(@"%s",__func__);
}

@end

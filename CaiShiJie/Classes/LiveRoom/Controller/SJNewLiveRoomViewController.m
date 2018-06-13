//
//  SJLiveRoomViewController.m
//  CaiShiJie
//
//  Created by user on 16/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNewLiveRoomViewController.h"
#import "SJOpinionViewController.h"
#import "SJInteractViewController.h"
#import "SJLiveGiftViewController.h"
#import "SJNewLiveVideoListViewController.h"
#import "SJNewLiveVideoTeacherViewController.h"
#import "SRWebSocket.h"
#import "SJNetManager.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "ZZPhotoKit.h"
#import "SJUploadParam.h"
#import "SJUserInfo.h"
#import "SJGiftModel.h"
#import "SJLoginViewController.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "SJNewLiveVideoAboveView.h"
#import "SJFullViewController.h"

#define enableBackgroundPlay 0

@interface SJNewLiveRoomViewController ()<UIScrollViewDelegate,UIAlertViewDelegate,SRWebSocketDelegate,PLPlayerDelegate>
{
    SRWebSocket *_webSocket;
    NSTimer *t; // 轮询
    BOOL isOpinion; // 判断是发送观点还是互动
}
@property (nonatomic, strong) UIView *playerViewBackgroundView;
@property (nonatomic, strong) UIView *menuBar;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak  ) UIButton *lastSelected;
@property (nonatomic, strong) NSMutableArray *menuBtnArr;
@property (nonatomic, strong) SJOpinionViewController *opinionVC;
@property (nonatomic, strong) SJInteractViewController *interactVC;
@property (nonatomic, strong) SJLiveGiftViewController *liveGiftVC;
@property (nonatomic, strong) SJNewLiveVideoListViewController *videoListVC;
@property (nonatomic, strong) SJNewLiveVideoTeacherViewController *videoTeacherVC;
@property (nonatomic, strong) NSDictionary *liveUserDict;// 直播用户者的信息
@property (nonatomic, copy  ) NSString *snMax;// 最大sn
@property (nonatomic, strong) NSString *replyid;// 回复item_id
@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) SJNewLiveVideoAboveView *liveVideoAboveView;
@property (nonatomic, strong) SJFullViewController *fullVC;
/**
 *  url 播放地址
 *  poster 封面图
 */
@property (nonatomic, strong) NSDictionary *livePathDic;
@property (nonatomic, assign) BOOL isFullScreen;

@end

@implementation SJNewLiveRoomViewController

- (SJFullViewController *)fullVC {
    if (!_fullVC) {
        _fullVC = [[SJFullViewController alloc] init];
    }
    return _fullVC;
}

- (NSMutableArray *)menuBtnArr {
    if (_menuBtnArr == nil) {
        _menuBtnArr = [NSMutableArray array];
    }
    return _menuBtnArr;
}

- (SJInteractViewController *)interactVC {
    if (_interactVC == nil) {
        _interactVC = [[SJInteractViewController alloc] init];
        _interactVC.target_id = self.target_id;
        [self addChildViewController:_interactVC];
    }
    return _interactVC;
}

- (SJOpinionViewController *)opinionVC {
    if (_opinionVC == nil) {
        _opinionVC = [[SJOpinionViewController alloc] init];
        _opinionVC.target_id = self.target_id;
        [self addChildViewController:_opinionVC];
    }
    return _opinionVC;
}

- (SJLiveGiftViewController *)liveGiftVC {
    if (_liveGiftVC == nil) {
        _liveGiftVC = [[SJLiveGiftViewController alloc] init];
        _liveGiftVC.targetid = self.target_id;
        [self addChildViewController:_liveGiftVC];
    }
    return _liveGiftVC;
}

- (SJNewLiveVideoListViewController *)videoListVC {
    if (_videoListVC == nil) {
        _videoListVC = [[SJNewLiveVideoListViewController alloc] init];
        _videoListVC.target_id = self.target_id;
        WS(weakSelf);
        _videoListVC.skipToVideoCourseBlock = ^() {
            if (weakSelf.player != nil && weakSelf.player.playing) {
                [weakSelf.player pause];
                [weakSelf.liveVideoAboveView setPlayButtonSelected:NO];
            }
        };
        [self addChildViewController:_videoListVC];
    }
    return _videoListVC;
}

- (SJNewLiveVideoTeacherViewController *)videoTeacherVC {
    if (_videoTeacherVC == nil) {
        _videoTeacherVC = [[SJNewLiveVideoTeacherViewController alloc] init];
        _videoTeacherVC.target_id = self.target_id;
        [self addChildViewController:_videoTeacherVC];
    }
    return _videoTeacherVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    // 默认发送观点
    isOpinion = YES;
    // 默认不是全屏
    self.isFullScreen = NO;
    [self setupChildViews];
    [self loadLiveVideoPath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // 获取直播主题
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self getLiveTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面将要消失的时候关闭服务器连接
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
    // 页面将要消失的时候关闭定时器
    [t invalidate];
}

#pragma mark - 获取直播主题
- (void)getLiveTitle {
    SJToken *instance = [SJToken sharedToken];
    [[SJNetManager sharedNetManager] requestLiveTitleWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.target_id andLiveid:@"" withSuccessBlock:^(NSDictionary *dict) {
        //SJLog(@"%@",dict);
        if ([dict[@"states"] isEqual:@"1"]) {
            self.liveUserDict = dict[@"data"];
            SJLog(@"+++%@",self.liveUserDict);
            self.videoListVC.total_count = self.liveUserDict[@"total_count"];
        
            // 判断是否为今日直播
            [self isOrNoTodayLive];
            // 获取观点和互动
            [self getViewAndInteraction];
        } else {
            [MBProgressHUD hideHUDForView:self.view];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1001;
            
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:error.localizedDescription delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 1002;
        
        [alert show];
    }];
}

#pragma mark - 判断是否为今日直播
- (void)isOrNoTodayLive
{
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    
    NSString *dateStr = [format stringFromDate:date];
    if (![self.liveUserDict[@"live_id"] isEqual:dateStr]) {
        // 发出通知禁止textfield编辑
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTextFieldStopEdit object:@"1"];
    } else {
        // 开始连接服务器
        [self reconnect];
        
        // 发出通知允许textfield编辑
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTextFieldAllowEdit object:nil];
    }
}

#pragma mark - 获取观点与互动
- (void)getViewAndInteraction
{
    [[SJNetManager sharedNetManager] requestViewAndInteractionWithUserid:self.target_id andLiveid:self.liveUserDict[@"live_id"] andPageindex:@"1" andPageSize:@"10" withSuccessBlock:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:self.view];
        
        NSArray *opinionArr = dict[@"opinion"];
        NSDictionary *opinionDict = @{@"opinion":opinionArr,@"liveInfo":self.liveUserDict};
        
        // 发送通知加载观点
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationLoadOpinion object:opinionDict];
        
        NSArray *interactArr = dict[@"interact"];
        NSDictionary *interactDict = @{@"interact":interactArr,@"liveInfo":self.liveUserDict};
        
        // 发送通知加载互动
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationLoadInteract object:interactDict];
        
        // 获取观点和互动中最大的sn
        NSDictionary *opDic = opinionArr.lastObject;
        NSDictionary *inDic = interactArr.lastObject;
        
        if ([opDic[@"sn"] intValue] > [inDic[@"sn"] intValue]) {
            self.snMax = opDic[@"sn"];
        } else {
            self.snMax = inDic[@"sn"];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 重新连接服务器
- (void)reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *urlStr = [NSString stringWithFormat:@"ws://%@/ws?u=%@&l=%@&sn=%@",imHost,[SJUserDefaults valueForKey:kUserid],self.target_id,self.snMax];
    SJLog(@"%@",urlStr);
    
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
    
    t = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(lunXunRequestData) userInfo:nil repeats:YES];
}
#pragma mark - 轮询请求数据
- (void)lunXunRequestData
{
    NSString *sn = [NSString stringWithFormat:@"%d",[self.snMax intValue] + 1];
    [[SJNetManager sharedNetManager] lunXunRequestDataWithUserid:[[NSUserDefaults standardUserDefaults] valueForKey:kUserid] andTargetid:self.target_id andSn:sn withSuccessBlock:^(NSDictionary *dict) {
        
        //SJLog(@"%@",dict);
        // 如果返回来的sn和传入的一样则没有数据
        if ([[NSString stringWithFormat:@"%@",dict[@"data"]]isEqualToString:@"<null>"]) {
            // 关闭定时器
            [t invalidate];
            // 开始连接socket服务器
            [self reconnect];
            return ;
        }
        
        self.snMax = dict[@"sn"];
        NSArray *tmpArr = dict[@"data"];
        NSMutableArray *opinionArr = [NSMutableArray array];
        NSMutableArray *interactArr = [NSMutableArray array];
        
        for (NSDictionary *tmpDict in tmpArr)
        {
            if ([tmpDict[@"type"] isEqual:@"21"]
                || [tmpDict[@"type"] isEqual:@"1"]
                || [tmpDict[@"type"] isEqual:@"2"]) {
                // 观点、送礼、红包
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSMutableDictionary *dictM = [tmpDict mutableCopy];
                [dictM removeObjectForKey:@"data"];
                dictM[@"data"] = jsonStr;
                [opinionArr addObject:dictM];
                
                //SJLog(@"%@",opinionArr);
                // 发出通知添加轮询观点
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddLunXunOpinion object:opinionArr];
            } else if ([tmpDict[@"type"] isEqual:@"40"]) {
                // 互动
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSMutableDictionary *dictM = [tmpDict mutableCopy];
                [dictM removeObjectForKey:@"data"];
                dictM[@"data"] = jsonStr;
                [interactArr addObject:dictM];
                
                // 发出通知添加轮询互动
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddLunXUnInteract object:interactArr];
            }
        }
        
        // 关闭定时器
        [t invalidate];
        // 开始连接服务器
        [self reconnect];
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    //NSLog(@"%@",dict);
    
    self.snMax = dict[@"sn"];
    if ([dict[@"type"] isEqual:@(21)]
        || [dict[@"type"] isEqual:@(1)]
        || [dict[@"type"] isEqual:@(2)]) {
        // 观点、送礼、红包
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictM = [dict mutableCopy];
        [dictM removeObjectForKey:@"data"];
        dictM[@"data"] = jsonStr;
        //SJLog(@"%@",dictM);
        
        // 通知添加观点
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddOpinion object:dictM];
    } else if ([dict[@"type"] isEqual:@(40)]) {
        // 互动
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictM = [dict mutableCopy];
        [dictM removeObjectForKey:@"data"];
        dictM[@"data"] = jsonStr;
        //SJLog(@"%@",dictM);
        
        // 通知添加互动
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationAddInteract object:dictM];
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    
    _webSocket = nil;
    
    t = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(lunXunRequestData) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}

- (void)setupChildViews {
    WS(weakSelf);
    _playerViewBackgroundView = [[UIView alloc] init];
    _playerViewBackgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerViewBackgroundView];
    [_playerViewBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(SJScreenW*9/16);
    }];
    
    _liveVideoAboveView = [[SJNewLiveVideoAboveView alloc] init];
    _liveVideoAboveView.liveVideoAboveViewButtonClickedBlock = ^(UIButton *button) {
        switch (button.tag) {
            case 201: {
                // 播放暂停
                if (!button.selected) {
                    // 播放
                    button.selected = !button.selected;
                    [weakSelf.player resume];

                } else {
                    // 暂停
                    if (weakSelf.player.playing) {
                        button.selected = !button.selected;
                        [weakSelf.player pause];
                    }
                }
            }
                break;
            case 202: {
                // 返回
                if (weakSelf.isFullScreen) {
                    [weakSelf exitFullScreen];
                } else {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
                break;
            case 203: {
                // 全屏
                if (weakSelf.isFullScreen) {
                    // 退出全屏
                    [weakSelf exitFullScreen];
                } else {
                    // 进入全屏
                    [weakSelf enterFullScreen];
                }
            }
                break;
            case 204: {
                // 中心播放按钮
                [weakSelf.player play];
            }
                break;
                
            default:
                break;
        }
    };
    [_playerViewBackgroundView addSubview:_liveVideoAboveView];
    [_liveVideoAboveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _menuBar = [[UIView alloc] init];
    _menuBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_menuBar];
    [_menuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.equalTo(weakSelf.playerViewBackgroundView.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.view.mas_left).offset(0);
        make.right.equalTo(weakSelf.view.mas_right).offset(0);
    }];
    
    [self setUpButtonWithTitle:@"观点" tag:101 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"互动" tag:102 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"直播" tag:103 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"送礼" tag:104 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"老师" tag:105 target:self action:@selector(btnClick:)];
    
    for (int i = 0; i < self.menuBtnArr.count; i++) {
        UIButton *btn = self.menuBtnArr[i];
        btn.frame = CGRectMake((SJScreenW / 5) * i, 0, SJScreenW / 5, 38);
        if (i == 0) {
            btn.selected = YES;
            self.lastSelected = btn;
        }
        [_menuBar addSubview:btn];
    }
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 38, SJScreenW / 5, 2)];
    _lineView.backgroundColor = RGB(247, 100, 8);
    [_menuBar addSubview:_lineView];
    
    _shadowView = [[UIImageView alloc] init];
    _shadowView.image = [UIImage imageNamed:@"live_title_border_radius"];
    [self.view addSubview:_shadowView];
    
    [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.menuBar.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(4);
    }];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.contentSize = CGSizeMake(SJScreenW * 5, _scrollView.height);
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.shadowView.mas_bottom).offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    [_scrollView addSubview:self.opinionVC.view];
    [_scrollView addSubview:self.interactVC.view];
    [_scrollView addSubview:self.videoListVC.view];
    [_scrollView addSubview:self.liveGiftVC.view];
    [_scrollView addSubview:self.videoTeacherVC.view];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *curView = (UIView *)obj;
        [curView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(_scrollView.height);
            make.width.mas_equalTo(SJScreenW);
            make.left.mas_equalTo(SJScreenW * idx);
        }];
    }];
}

- (void)enterFullScreen {
    [self.fullVC.view addSubview:self.player.playerView];
    [self.fullVC.view addSubview:self.liveVideoAboveView];
    [self.player.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.liveVideoAboveView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self presentViewController:self.fullVC animated:NO completion:^{
        self.isFullScreen = YES;
    }];
}

- (void)exitFullScreen {
    [self.playerViewBackgroundView addSubview:self.player.playerView];
    [self.playerViewBackgroundView addSubview:self.liveVideoAboveView];
    [self.player.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.liveVideoAboveView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.fullVC dismissViewControllerAnimated:NO completion:^{
        self.isFullScreen = NO;
    }];
}

#pragma mark - 获取直播播放地址
- (void)loadLiveVideoPath {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/video?user_id=%@", HOST, self.target_id];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"status"] isEqualToString:@"1"] && respose[@"data"] != nil) {
            self.livePathDic = respose[@"data"];
            //SJLog(@"%@", self.livePathDic[@"url"]);
            // 根据播放地址创建直播流播放器
            [self setupPLPlayerWithUrlString:self.livePathDic[@"url"]];
        } else {
            [MBProgressHUD showError:@"获取播放地址失败" toView:self.playerViewBackgroundView];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.playerViewBackgroundView];
    }];
}

- (void)setupPLPlayerWithUrlString:(NSString *)urlStr {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    [option setOptionValue:@(YES) forKey:PLPlayerOptionKeyVideoToolbox];
    [option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
    [option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
    
    
    self.player = [PLPlayer playerWithURL:[NSURL URLWithString:urlStr] option:option];
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    self.player.backgroundPlayEnable = enableBackgroundPlay;
#if !enableBackgroundPlay
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlayer) name:UIApplicationWillEnterForegroundNotification object:nil];
#endif
    [self setupPlayerView];
    [self startPlayer];
}

- (void)setupPlayerView {
    if (self.player.status != PLPlayerStatusError && !self.player.playerView.superview) {
        self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
        [self.playerViewBackgroundView addSubview:self.player.playerView];
        [self.playerViewBackgroundView sendSubviewToBack:self.player.playerView];
        [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
}

- (void)startPlayer {
    [self.liveVideoAboveView setPlayButtonAndFullButtonHide:YES];
    [self.liveVideoAboveView showCenterButton];
    [self.liveVideoAboveView showCoverPicture];
    [self.liveVideoAboveView setCoverPictureWithUrlString:self.livePathDic[@"poster"]];
    [self.player play];
}

#pragma mark - <PLPlayerDelegate>
- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    SJLog(@"回调状态：---%ld---", state);
    if (PLPlayerStatusCaching == state) {
        [self.liveVideoAboveView setProgressHUDMessage:@"缓冲中..."];
        [self.liveVideoAboveView showProgressHUD];
        [self.liveVideoAboveView HideCenterButton];
        [self.liveVideoAboveView addSingleGesture];
        [self.liveVideoAboveView setPlayButtonSelected:YES];
    } else if (PLPlayerStatusPlaying == state) {
        [self.liveVideoAboveView hideProgressHUD];
        [self.liveVideoAboveView HideCenterButton];
        [self.liveVideoAboveView HideCoverPicture];
        [self.liveVideoAboveView setPlayButtonAndFullButtonHide:NO];
    }
}

- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error {
    SJLog(@"回调错误状态：---%@---", error);
    [MBProgressHUD showError:@"视频直播未开始" toView:self.playerViewBackgroundView];
    [self.liveVideoAboveView hideProgressHUD];
    [self.liveVideoAboveView removeSingleGesture];
    [self.liveVideoAboveView setPlayButtonAndFullButtonHide:YES];
    [self.liveVideoAboveView setPlayButtonSelected:NO];
    [self.liveVideoAboveView showCenterButton];
    [self.liveVideoAboveView showCoverPicture];
    [self.liveVideoAboveView setCoverPictureWithUrlString:self.livePathDic[@"poster"]];
}
/*
- (void)tryReconnect:(NSError *)error {
    if (self.reconnectCount < 1) {
        _reconnectCount++;
        [self.liveVideoAboveView setProgressHUDMessage:@"正在重连..."];
        [self.liveVideoAboveView showProgressHUD];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pow(2, self.reconnectCount) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.player play];
        });
    } else {
        self.reconnectCount = 0; // 重新初始化
        [MBProgressHUD showError:@"直播未开始" toView:self.playerViewBackgroundView];
        [self.liveVideoAboveView hideProgressHUD];
        [self.liveVideoAboveView removeSingleGesture];
        [self.liveVideoAboveView setPlayButtonAndFullButtonHide:YES];
        [self.liveVideoAboveView setPlayButtonSelected:NO];
        [self.liveVideoAboveView showCenterButtonAndCoverPicture];
        [self.liveVideoAboveView setCoverPictureWithUrlString:self.livePathDic[@"poster"]];
    }
}
*/
- (void)setUpButtonWithTitle:(NSString *)title tag:(NSInteger)tag target:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:RGB(247, 100, 8) forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    
    [self.menuBtnArr addObject:btn];
}

#pragma mark - 点击菜单事件
- (void)btnClick:(UIButton *)button {
    [self setUpAnimateWith:button];
    [self.scrollView setContentOffset:CGPointMake(SJScreenW * (button.tag - 101), 0) animated:NO];
    
    if ([button isEqual:self.lastSelected]) {
        return;
    } else {
        button.selected = YES;
        self.lastSelected.selected = NO;
        self.lastSelected = button;
    }
    
    // 发送通知取消第一响应
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationResignFirstResponder object:nil];
}

#pragma mark - UIScrollViewDelegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    [self moveToIndex:offset];
    
    if (offset <= 0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)moveToIndex:(float)x {
    CGRect rect = self.lineView.frame;
    rect.origin.x = self.lineView.frame.size.width * x;
    self.lineView.frame = rect;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    
    int index = offset;
    for (int i = 0; i < self.menuBtnArr.count; i++) {
        UIButton *btn = self.menuBtnArr[i];
        // 判断当前应该选中哪个
        if (btn.tag == index + 101) {
            // 判断当前按钮是否是选中状态
            if (![btn isEqual:self.lastSelected]) {
                btn.selected = YES;
                self.lastSelected.selected = NO;
                self.lastSelected = btn;
                break;
            }
        }
    }
    
    // 发送通知取消第一响应
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationResignFirstResponder object:nil];
}

#pragma mark - 设置动画效果
- (void)setUpAnimateWith:(UIButton *)button {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.lineView.frame;
        rect.origin.x = button.frame.origin.x;
        self.lineView.frame = rect;
    } completion:^(BOOL finished) {
        // 获取到当前的View
        CALayer *viewLayer = self.lineView.layer;
        // 获取当前View的位置
        CGPoint position = viewLayer.position;
        // 移动的两个终点位置
        CGPoint x = CGPointMake(position.x + 5, position.y);
        CGPoint y = CGPointMake(position.x - 5, position.y);
        // 设置动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        // 设置运动形式
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        // 设置开始位置
        [animation setFromValue:[NSValue valueWithCGPoint:x]];
        // 设置结束位置
        [animation setToValue:[NSValue valueWithCGPoint:y]];
        // 设置自动反转
        [animation setAutoreverses:YES];
        // 设置时间
        [animation setDuration:0.03];
        // 设置次数
        [animation setRepeatCount:3];
        // 添加上动画
        [viewLayer addAnimation:animation forKey:nil];
    }];
}

#pragma mark - UIAlertViewDelegate 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (alertView.tag == 1002) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

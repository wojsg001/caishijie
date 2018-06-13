//
//  AppDelegate.m
//  CaiShiJie
//
//  Created by user on 15/12/21.
//  Copyright © 2015年 user. All rights reserved.
//

#import "AppDelegate.h"
#import "SJGuideTool.h"
#import <UMShare/UMShare.h>
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <UMCommonLog/UMCommonLogHeaders.h>
#import <UMAnalytics/MobClick.h>
#import "iflyMSC/IFlyMSC.h"
#import "BeeCloud.h"
#import "SJNetManager.h"
#import "SJhttptool.h"
#import "SXAdManager.h"
#import "KINWebBrowserViewController.h"
#import "AFNetworking.h"
#import "MQTTSessionManager.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import <PLPlayerKit/PLPlayerEnv.h>
#import "PLMediaStreamingKit.h"

static AppDelegate *_appDelegate = nil;

@interface AppDelegate ()<MQTTSessionManagerDelegate>
{
    NSTimer *t;
    int time;
    MQTTSessionManager *sessionManager;
}
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, assign) NSString *unreadMessageCount;

@end

@implementation AppDelegate

/**
 *  方法功能：获取AppDelegate的实例
 */
+ (AppDelegate*)getAppDelegate {
    return _appDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    _appDelegate = self;
    
    [PLPlayerEnv initEnv];
    [PLStreamingEnv initEnv];
    
    // 添加对网络的监听
    [self checkAFNetworkStatus];
    
    // 添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitLogin) name:KNotificationExitLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageUnreadCountChange:) name:KNotificationChatMessageUnreadCount object:nil];
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        // 加载未读消息数量
        [self loadUnreadMessageCount];
        // 如果用户已登录开始连接MQTT
        [self connectMQTT];
    }
    // 设置配置信息
    [self setupConfiguration];
    
    // Push's basic setting
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert;
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }else
        {
        }
    }];
    
    // 创建窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [SJGuideTool guideRootViewController:self.window];
    // 显示窗口
    [self.window makeKeyAndVisible];
    // 添加广告
    [self addADView];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    SJLog(@"----Token----%@", deviceToken);
    NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                 stringByReplacingOccurrencesOfString: @" " withString: @""]);
}

//iOS10以下使用这两个方法接收通知
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage setAutoAlert:NO];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于前台时的本地推送接受
    }
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于后台时的本地推送接受
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    SJLog(@"----userInfo----%@", userInfo);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    SJLog(@"---RegisterFail---%@", error);
}

#pragma mark - 添加系统回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    // 为保证从微信，QQ，微博返回本应用
    if (!result) {
        
    }
    // 为保证从支付宝，微信返回本应用，须绑定openUrl.
    if (![BeeCloud handleOpenUrl:url]) {
        
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    // 为保证从微信，QQ，微博返回本应用
    if (!result) {
        
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 程序从后台进入前台重新加载消息未读数量
    [self loadUnreadMessageCount];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 检查网络状态
- (void)checkAFNetworkStatus
{
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里是监测到网络改变的block可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                SJLog(@"未知网络状态");
                self.isNetworkReachable = YES;
                self.isNetworkReachableWiFi = NO;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                SJLog(@"无网络");
                self.isNetworkReachable = NO;
                self.isNetworkReachableWiFi = NO;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                SJLog(@"蜂窝数据网");
                self.isNetworkReachable = YES;
                self.isNetworkReachableWiFi = NO;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                SJLog(@"WiFi网络");
                self.isNetworkReachable = YES;
                self.isNetworkReachableWiFi = YES;
                break;
                
            default:
                break;
        }
        
        // 网络状态改变发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationNetworkStatusChange object:[NSNumber numberWithInteger:status]];
    }] ;
    //开始监听
    [manager startMonitoring];
}

#pragma mark - 添加广告页
- (void)addADView
{
    time = 5;
    [SXAdManager loadLatestAdImage];
    if ([SXAdManager isShouldDisplayAd]) {
        // ------这里主要是容错一个bug。
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"top20"];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"rightItem"];
        
        _adView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        UIImageView *adImg = [[UIImageView alloc]initWithImage:[SXAdManager getAdImage]];
        UIImageView *adBottomImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"adBottom.png"]];
        [_adView addSubview:adBottomImg];
        [_adView addSubview:adImg];
        adBottomImg.frame = CGRectMake(0, SJScreenH - SJScreenW * 256/750, SJScreenW, SJScreenW * 256/750);
        adImg.frame = CGRectMake(0, 0, SJScreenW, SJScreenH - SJScreenW * 256/750);
        UIButton *btn = [[UIButton alloc] init];
        btn.backgroundColor = [UIColor clearColor];
        btn.frame = CGRectMake(0, 0, SJScreenW, SJScreenH - SJScreenW * 256/750);
        [btn addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchUpInside];
        [_adView addSubview:btn];
        
        _skipButton = [[UIButton alloc] init];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"skip_btn"] forState:UIControlStateNormal];
        [_skipButton setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
        [_skipButton setTitle:@"5s跳过" forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [_skipButton addTarget:self action:@selector(skipAdView) forControlEvents:UIControlEventTouchUpInside];
        [_adView addSubview:_skipButton];

        
        [_skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(25);
            make.right.mas_equalTo(-15);
        }];
        
        
        _adView.alpha = 1.0f;
        [self.window addSubview:_adView];
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        // 5秒后移除广告页
        t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(removeAdView) userInfo:nil repeats:YES];
        
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"update"];
    }
}

// 移除广告图
- (void)removeAdView
{
    time--;
    
    [_skipButton setTitle:[NSString stringWithFormat:@"%is跳过",time] forState:UIControlStateNormal];
    
    if (time == 0) {
        [t invalidate];
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            _adView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [_adView removeFromSuperview];
        }];
    }

}
// 跳过广告
- (void)skipAdView
{
    [t invalidate];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _adView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_adView removeFromSuperview];
    }];
}

// 图片点击事件
- (void)buttonDown
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kAdUrlStr])
    {
        [self skipAdView];
        UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
        KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowser];
        webBrowser.showsURLInNavigationBar = YES;
        webBrowser.showsPageTitleInNavigationBar = NO;
        [SJKeyWindow.rootViewController presentViewController:webBrowserNavigationController animated:YES completion:nil];
        
        [webBrowser loadURLString:[[NSUserDefaults standardUserDefaults] valueForKey:kAdUrlStr]];
    }
}
#pragma mark - 设置配置信息
- (void)setupConfiguration {
    
    //打开加密传输
    [UMConfigure setEncryptEnabled:YES];
    
    //开发者需要显式的调用此函数，日志系统才能工作
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMConfigure setLogEnabled:YES];
    
    // 开启Crash收集
    [MobClick setCrashReportEnabled:YES];
    
    //设置友盟appkey
    [UMConfigure initWithAppkey:UMENG_APPKEY channel:@"App Store"];
    
    [MobClick setScenarioType:E_UM_GAME|E_UM_DPLUS];
    
    //各平台的详细配置
    //设置分享到QQ互联的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"101280116" appSecret:@"084eca13aa3ba41b653baf81b6308a9a" redirectURL:@"http://www.18csj.com"]; ////QQ聊天页面
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Qzone appKey:@"101280116" appSecret:@"084eca13aa3ba41b653baf81b6308a9a" redirectURL:@"http://www.18csj.com"];////qq空间
    //设置微信的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession  appKey:@"wx08a034f206b96be5" appSecret:@"2249fe73b6efd7bf16724c54b6fd2a44" redirectURL:@"http://www.18csj.com"]; //微信聊天
   [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatTimeLine appKey:@"wx08a034f206b96be5" appSecret:@"2249fe73b6efd7bf16724c54b6fd2a44" redirectURL:@"http://www.18csj.com"]; //微信朋友圈
    //设置新浪的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1260789526" appSecret:@"1843a9cd69a4bcbba528b1c384aaa9b9" redirectURL:@"http://sns.whalecloud.com/sina2/callback"]; ////新浪

    /*
     创建语音配置,appid必须要传入，仅执行一次则可
     所有服务启动前，需要确保执行createUtility
     */
    [IFlySpeechUtility createUtility:@"appid=56e76742"];
    /*
     如果使用BeeCloud控制台的APP Secret初始化，代表初始化生产环境；
     */
    [BeeCloud initWithAppID:@"0307998b-ecce-40d4-ba15-5eec11d2b63d" andAppSecret:@"7e210716-7cbb-4392-8bd4-ad4591c0115f"];
    //初始化微信
    [BeeCloud initWeChatPay:@"wx08a034f206b96be5"];
}
#pragma mark - NSNotification
- (void)loginSuccess {
    // 加载未读消息数量
    [self loadUnreadMessageCount];
    // 登录成功开始连接MQTT
    [self connectMQTT];
}

- (void)exitLogin {
    // 退出登录关闭MQTT
    if (sessionManager) {
        [sessionManager disconnect];
    }
    _unreadMessageCount = @"0"; // 归零
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    [[[tabBarController.viewControllers objectAtIndex:4] tabBarItem] setBadgeValue:_unreadMessageCount];
}

- (void)chatMessageUnreadCountChange:(NSNotification *)n {
    _unreadMessageCount = [NSString stringWithFormat:@"%@", n.object];
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    [[[tabBarController.viewControllers objectAtIndex:4] tabBarItem] setBadgeValue:_unreadMessageCount];
}
#pragma mark - 开始连接MQTT
- (void)connectMQTT {
    if (!sessionManager) {
        sessionManager = [[MQTTSessionManager alloc] init];
        sessionManager.delegate = self;
        [sessionManager addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
    }

    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInfo];
    NSString *user = [NSString stringWithFormat:@"u%@", dic[@"user_id"]];
    NSString *pass = [NSString stringWithFormat:@"%@", dic[@"token"]];
    [sessionManager connectTo:MQTTHost
                          port:1883
                           tls:NO
                     keepalive:60
                         clean:YES
                          auth:YES
                          user:user
                          pass:pass
                     willTopic:@""
                          will:[NSData data]
                       willQos:MQTTQosLevelAtMostOnce
                willRetainFlag:NO
                  withClientId:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (sessionManager.state) {
        case MQTTSessionManagerStateClosed: //连接已经关闭
            SJLog(@"连接已经关闭");
            break;
        case MQTTSessionManagerStateClosing: //连接正在关闭
            SJLog(@"连接正在关闭");
            break;
        case MQTTSessionManagerStateConnected: //已经连接
            SJLog(@"已经连接");
            break;
        case MQTTSessionManagerStateConnecting: //正在连接中
            SJLog(@"正在连接中");
            break;
        case MQTTSessionManagerStateError: //异常
            SJLog(@"异常");
            break;
        case MQTTSessionManagerStateStarting: //开始连接
            SJLog(@"开始连接");
        default:
            break;
    }
}

#pragma mark - MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    SJLog(@"%@", dictionary);
    if (dictionary) {
        // 如何数据不为空
        _unreadMessageCount = [NSString stringWithFormat:@"%ld", [_unreadMessageCount integerValue] + 1];
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        [[[tabBarController.viewControllers objectAtIndex:4] tabBarItem] setBadgeValue:_unreadMessageCount];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMQTTHaveNewData object:dictionary];
    }
}

- (void)loadUnreadMessageCount {
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/message/unread-count?user_id=%@&token=%@&time=%@", HOST, instance.userid, instance.token, instance.time];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        if ([respose[@"status"] integerValue] && [respose[@"data"] integerValue]) {
            _unreadMessageCount = [NSString stringWithFormat:@"%@", respose[@"data"]];
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            [[[tabBarController.viewControllers objectAtIndex:4] tabBarItem] setBadgeValue:_unreadMessageCount];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (sessionManager) {
        [sessionManager removeObserver:self forKeyPath:@"state"];
    }
}

@end

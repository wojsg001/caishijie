//
//  SJMyLiveViewController.m
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyLiveViewController.h"
#import "SJNetManager.h"
#import "SRWebSocket.h"
#import "SJToken.h"
#import "SJTitleView.h"
#import "SJLiveManageViewController.h"
#import "SJUserInfo.h"
#import "SJOldLiveViewController.h"
#import "SJPersonalArticleViewController.h"
#import "SJHisReferenceViewController.h"

@interface SJMyLiveViewController ()<UIScrollViewDelegate,UIAlertViewDelegate, SRWebSocketDelegate,SJLiveManageViewControllerDelegate>
{
    SJNetManager *netManager;
    SRWebSocket *_webSocket;
    NSTimer *t; // 轮询
    BOOL isOpinion; // 判断是发送观点还是互动
}

@property (nonatomic, strong) SJTitleView *titleView;
@property (nonatomic, strong) NSDictionary *liveUserDict;// 视频用户者的信息
@property (nonatomic, assign) NSInteger snMax;// 最大sn
@property (nonatomic, strong) NSString *replyid;// 回复item_id
@property (nonatomic, strong) SJLiveManageViewController *liveManagerVC;

@end

@implementation SJMyLiveViewController

- (SJLiveManageViewController *)liveManagerVC
{
    if (_liveManagerVC == nil) {
        _liveManagerVC = [[SJLiveManageViewController alloc] init];
        _liveManagerVC.delegate = self;
        _liveManagerVC.target_id = self.target_id;
    }
    return _liveManagerVC;
}

- (SJTitleView *)titleView
{
    if (_titleView == nil) {
        _titleView = [[NSBundle mainBundle] loadNibNamed:@"SJTitleView" owner:nil options:nil].lastObject;
        _titleView.frame = CGRectMake(0, 0, 180, 44);
    }
    return _titleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.liveManagerVC.view.frame = self.view.bounds;
    [self.view addSubview:self.liveManagerVC.view];
    [self addChildViewController:self.liveManagerVC];

    self.navigationItem.titleView = self.titleView;
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationItem.titleView.mas_centerY).offset(-10);
    }];

    // 默认发送观点
    isOpinion = YES;
    netManager = [SJNetManager sharedNetManager];
    
    if (self.live_id == nil) {
        self.live_id = @"";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 获取视频主题
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self getLiveTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - 判断是否为今日视频
- (void)isOrNoTodayLive
{
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [format stringFromDate:date];
    if (![self.liveUserDict[@"live_id"] isEqual:dateStr]) {
        //SJLog(@"%i",[dateStr integerValue]);
        self.titleView.stateLabel.text = @"视频已结束";
        // 发出通知禁止textfield编辑
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTextFieldStopEdit object:@"1"];
    } else {
        self.titleView.stateLabel.text = @"视频中";
        // 开始连接服务器
        [self reconnect];
        // 发出通知允许textfield编辑
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTextFieldAllowEdit object:nil];
    }
}

#pragma mark - 获取视频主题
- (void)getLiveTitle
{
    SJToken *instance = [SJToken sharedToken];
    [netManager requestLiveTitleWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.target_id andLiveid:self.live_id withSuccessBlock:^(NSDictionary *dict) {
        
        //SJLog(@"%@",dict);
        if ([dict[@"states"] isEqual:@"1"]) {
            self.liveUserDict = dict[@"data"];
            SJLog(@"+++%@",self.liveUserDict);
            
            // 给界面控件赋值
            [self setUpChildView];
            // 判断是否为今日视频
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
#pragma mark - 给界面控件赋值
- (void)setUpChildView
{
    self.liveManagerVC.titleLabel.text = self.liveUserDict[@"title"];
    self.liveManagerVC.attentionLabel.text = self.liveUserDict[@"total_count"];
    
    [self.titleView.head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,self.liveUserDict[@"head_img"]]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    self.titleView.nameLabel.text = self.liveUserDict[@"nickname"];
}

#pragma mark - 获取观点与互动
- (void)getViewAndInteraction
{
    [netManager requestViewAndInteractionWithUserid:self.target_id andLiveid:self.liveUserDict[@"live_id"] andPageindex:@"1" andPageSize:@"10" withSuccessBlock:^(NSDictionary *dict) {
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
        self.snMax = MAX([opDic[@"sn"] intValue], [inDic[@"sn"] intValue]);
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
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

#pragma mark - 重新连接服务器
- (void)reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *urlStr = [NSString stringWithFormat:@"ws://%@/ws?u=%@&l=%@&sn=%d",imHost,self.user_id,self.target_id,self.snMax];
    SJLog(@"%@",urlStr);
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    SJLog(@"Websocket Connected");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    SJLog(@":( Websocket Failed With Error %@", error);
    
    t = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(lunXunRequestData) userInfo:nil repeats:YES];
}
#pragma mark - 轮询请求数据
- (void)lunXunRequestData
{
    NSString *sn = [NSString stringWithFormat:@"%d", self.snMax + 1];
    [netManager lunXunRequestDataWithUserid:self.user_id andTargetid:self.target_id andSn:sn withSuccessBlock:^(NSDictionary *dict) {
        // SJLog(@"%@",dict);
        // 如果返回来的sn和传入的一样则没有数据
        if ([[NSString stringWithFormat:@"%@",dict[@"data"]]isEqualToString:@"<null>"]) {
            // 关闭定时器
            [t invalidate];
            // 开始连接socket服务器
            [self reconnect];
            return ;
        }
        
        self.snMax = [dict[@"sn"] integerValue];
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
    SJLog(@"Received \"%@\"", message);
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //SJLog(@"%@",dict);
    
    self.snMax = [dict[@"sn"] integerValue];
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
    SJLog(@"WebSocket closed");
    
    _webSocket = nil;
    
    t = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(lunXunRequestData) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    SJLog(@"Websocket received pong");
}

#pragma mark - SJLiveManageViewControllerDelegate 代理方法
- (void)ClickWhichButton:(NSInteger)index
{
    if (self.isOldLive) {
        // 如果是从历史视频页进入本界面时，提示不允许交互
        [MBHUDHelper showWarningWithText:@"当前页面不允许交互！"];
        return;
    }
    
    switch (index) {
        case 101: {
            // 博文
            SJPersonalArticleViewController *personalArticleVC = [[SJPersonalArticleViewController alloc] init];
            
            personalArticleVC.userid = self.target_id;
            personalArticleVC.title = @"他的博文";
            [self.navigationController pushViewController:personalArticleVC animated:YES];
            
        }
            break;
        case 102: {
            // 内参
            SJHisReferenceViewController *hisReferenceVC = [[SJHisReferenceViewController alloc] init];
            hisReferenceVC.title = @"他的内参";
            hisReferenceVC.user_id = self.target_id
            ;
            [self.navigationController pushViewController:hisReferenceVC animated:YES];
        }
            break;
        case 103: {
            // 历史视频
            SJOldLiveViewController *oldLiveVC = [[SJOldLiveViewController alloc] init];
            oldLiveVC.title = @"历史视频";
            oldLiveVC.userid = self.target_id;
            [self.navigationController pushViewController:oldLiveVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

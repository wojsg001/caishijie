//
//  SJPersonalCenterViewController.m
//  CaiShiJie
//
//  Created by user on 18/9/28.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalCenterViewController.h"
#import "UIColor+helper.h"
//#import "SJPersonalHomeViewController.h" //去掉主页原有功能
#import "SJPersonalOldLiveViewController.h"
#import "SJPersonalReferenceViewController.h"
#import "SJPersonalSummaryViewController.h"
#import "SJPersonalQuestionViewController.h"
#import "SJChatMessageViewController.h"
#import "SJhttptool.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import "MJExtension.h"
#import "SJComposeViewController.h"
#import "SJLoginViewController.h"
#import "SRWebSocket.h"
#import "SJNetManager.h"
#import "SJInteractViewController.h"

#define kPassUserInfoNotification @"TeacherInfo"

@implementation SJPersonalInfoModel

@end

@interface SJPersonalCenterViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *_pan;
    CameraMoveDirection _direction;
    BOOL _isCanScrollTop;
    BOOL _isCanScrollBottom;
    
    SJNetManager *netManager;
    SRWebSocket *_webSocket;
    NSTimer *t; // 轮询
    BOOL isOpinion; // 判断是发送观点还是互动
}
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UIButton *addAttentionButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *questionButton;
@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, strong) NSDictionary *teacherInfoDic;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBackgroundViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconBackgroundViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconBackgroundViewCenterYConstraint;

@property (nonatomic, strong) NSDictionary *liveUserDict;// 直播用户者的信息
@property (nonatomic, assign) NSInteger snMax;// 最大sn
@property (nonatomic, strong) NSString *replyid;// 回复item_id

@end

@implementation SJPersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self addChildViewControllers];
    [self initChildViews];

    // 添加默认控制器
    UIViewController *firstVC = [self.childViewControllers firstObject];
    firstVC.view.frame = self.contentScrollView.bounds;
    [self.contentScrollView addSubview:firstVC.view];
    // 加载数据
    [self loadPersonalData];
    

    // 默认发送观点
    isOpinion = YES;
    netManager = [SJNetManager sharedNetManager];
    
    if (self.live_id == nil) {
        self.live_id = @"";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getViewAndInteraction) name:KNotificatioNInteractRefresh object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 获取直播主题
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self getLiveTitle];
}

#pragma mark - 获取直播主题
- (void)getLiveTitle
{
    SJToken *instance = [SJToken sharedToken];
    [netManager requestLiveTitleWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.target_id andLiveid:self.live_id withSuccessBlock:^(NSDictionary *dict) {
        
        //SJLog(@"%@",dict);
        if ([dict[@"states"] isEqual:@"1"]) {
            self.liveUserDict = dict[@"data"];
            SJLog(@"+++%@",self.liveUserDict);
            
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
        //SJLog(@"%i",[dateStr integerValue]);
//        self.titleView.stateLabel.text = @"直播已结束";
        // 发出通知禁止textfield编辑
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTextFieldStopEdit object:@"1"];
    } else {
//        self.titleView.stateLabel.text = @"直播中";
        // 开始连接服务器
        [self reconnect];
        // 发出通知允许textfield编辑
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTextFieldAllowEdit object:nil];
    }
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

#pragma mark - 接收登录成功通知
- (void)loginSuccess {
    [self loadPersonalData];
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
    NSString *sn = [NSString stringWithFormat:@"%ld", self.snMax + 1];
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


//老师信息
- (void)loadPersonalData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/getteacherinfo", HOST];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:self.target_id forKey:@"targetid"];
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJToken *instance = [SJToken sharedToken];
        [params setObject:instance.token forKey:@"token"];
        [params setObject:instance.userid forKey:@"userid"];
        [params setObject:instance.time forKey:@"time"];
    }
    [SJhttptool GET:urlStr paramers:params success:^(id respose) {
        SJLog(@"%@", respose);
        if ([respose[@"status"] isEqualToString:@"1"]) {
            SJPersonalInfoModel *model = [SJPersonalInfoModel objectWithKeyValues:respose[@"data"]];
            [self updateUIWithModel:model];
            // 将老师信息传递到主页填充头像和昵称
            self.teacherInfoDic = respose[@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPassUserInfoNotification object:self.teacherInfoDic];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (void)updateUIWithModel:(SJPersonalInfoModel *)model {
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, model.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    self.nameLabel.text = model.nickname;
    self.summaryLabel.text = model.summary;
    NSInteger fans_count = [model.fans_count integerValue];
    if (fans_count < 10000) {
        self.fansLabel.text = [NSString stringWithFormat:@"粉丝：%@", model.fans_count];
    } else {
        self.fansLabel.text = [NSString stringWithFormat:@"粉丝：%.1f万", fans_count/10000.0];
    }
    if ([model.is_focus isEqualToString:@"1"]) {
        // 已关注
        self.addAttentionButton.selected = YES;
        [self.addAttentionButton setImage:[UIImage imageNamed:@"guanzhu"] forState:UIControlStateNormal];
        [self.addAttentionButton setTitle:@"已关注" forState:UIControlStateNormal];
    } else {
        // 未关注
        self.addAttentionButton.selected = NO;
        [self.addAttentionButton setImage:[UIImage imageNamed:@"HomePage_icon1"] forState:UIControlStateNormal];
        [self.addAttentionButton setTitle:@"未关注" forState:UIControlStateNormal];
    }
}

- (void)initChildViews {
    self.headImage.layer.cornerRadius = 35;
    self.headImage.layer.masksToBounds = YES;
    self.addAttentionButton.layer.cornerRadius = 5.0f;
    self.addAttentionButton.layer.masksToBounds = YES;
    self.addAttentionButton.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.addAttentionButton.layer.borderWidth = 0.5;
    self.privacyButton.layer.cornerRadius = 5.0f;
    self.privacyButton.layer.masksToBounds = YES;
    self.privacyButton.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.privacyButton.layer.borderWidth = 0.5;
    self.questionButton.layer.cornerRadius = 5.0f;
    self.questionButton.layer.masksToBounds = YES;
    self.questionButton.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.questionButton.layer.borderWidth = 0.5;
    
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.delegate = self;
    CGFloat contentX = self.childViewControllers.count * SJScreenW;
    self.contentScrollView.contentSize = CGSizeMake(contentX, 0);
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = NO;
    
    _isCanScrollTop = YES;
    _isCanScrollBottom = NO;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    _pan = pan;
    pan.delegate = self;
    pan.delaysTouchesBegan = YES;
    [self.contentScrollView addGestureRecognizer:pan];
}

- (void)panView:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:pan.view];
    //SJLog(@"%@", NSStringFromCGPoint(point));
    if (pan.state == UIGestureRecognizerStateBegan) {
        _direction = kCameraMoveDirectionNone;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (fabs(point.y) > 1.0) {
            if (_direction == kCameraMoveDirectionNone) {
                if (point.y > 0.0)
                    _direction = kCameraMoveDirectionDown;
                else
                    _direction = kCameraMoveDirectionUp;
            }
        }
        // 实时滚动
        [self slideWithTranslation:point.y];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        // 手势结束后滚动
        [self slideAnimationWithY:point.y];
    }
}

- (void)slideWithTranslation:(CGFloat)value {
    if (_direction == kCameraMoveDirectionDown && _isCanScrollBottom) {
        if (64 + value >= 64 && 64 + value <= 250) {
            self.titleBackgroundViewTopConstraint.constant = 64 + value;
        }
        if (32 + value >= 32 && 32 + value <= 135) {
            self.nameLabelTopConstraint.constant = 32 + value;
        }
        CGFloat iconConstraint = -(30 + CGRectGetWidth(self.nameLabel.frame) / 2) + value;
        if (iconConstraint > 0 && iconConstraint <= 45) {
            self.iconBackgroundViewTopConstraint.constant = iconConstraint;
        }
        if (iconConstraint <= 0 && iconConstraint >= -(30 + CGRectGetWidth(self.nameLabel.frame) / 2)) {
            self.iconBackgroundViewCenterYConstraint.constant = iconConstraint;
            CGFloat scale = 1;
            if (value <= 40) {
                scale = 0.5 + value / 40 * 0.5;
            }
            self.iconBackgroundView.transform = CGAffineTransformMakeScale(scale, scale);
            self.headImage.transform = CGAffineTransformMakeScale(scale, scale);
        }
    } else if (_direction == kCameraMoveDirectionUp && _isCanScrollTop) {
        if (250 + value >= 64 && 250 + value <= 250) {
            self.titleBackgroundViewTopConstraint.constant = 250 + value;
        }
        if (135 + value + 83 >= 32 && 135 + value + 83 <= 135) {
            self.nameLabelTopConstraint.constant = 135 + value + 83;
        }
        CGFloat iconConstraint = 45 + value + 83;
        if (iconConstraint >= 0 && iconConstraint <= 45) {
            self.iconBackgroundViewTopConstraint.constant = iconConstraint;
        }
        if (iconConstraint < 0 && fabs(iconConstraint) <= (30 + CGRectGetWidth(self.nameLabel.frame) / 2)) {
            self.iconBackgroundViewCenterYConstraint.constant = iconConstraint;
            CGFloat scale = 0.5;
            if (iconConstraint >= -40) {
                scale = 1 + iconConstraint / 40 * 0.5;
            }
            self.iconBackgroundView.transform = CGAffineTransformMakeScale(scale, scale);
            self.headImage.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
}

- (void)slideAnimationWithY:(CGFloat)value {
    if (_direction == kCameraMoveDirectionDown && _isCanScrollBottom) {
        if (value > 80) {
            self.titleBackgroundViewTopConstraint.constant = 250;
            self.nameLabelTopConstraint.constant = 135;
            self.iconBackgroundViewTopConstraint.constant = 45;
            self.iconBackgroundViewCenterYConstraint.constant = 0;
            self.iconBackgroundView.transform = CGAffineTransformMakeScale(1, 1);
            self.headImage.transform = CGAffineTransformMakeScale(1, 1);
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                _isCanScrollTop = YES;
                _isCanScrollBottom = NO;
            }];
        } else {
            self.titleBackgroundViewTopConstraint.constant = 64;
            self.nameLabelTopConstraint.constant = 32;
            self.iconBackgroundViewTopConstraint.constant = 0;
            self.iconBackgroundViewCenterYConstraint.constant = -(30 + CGRectGetWidth(self.nameLabel.frame) / 2);
            self.iconBackgroundView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            self.headImage.transform = CGAffineTransformMakeScale(0.5, 0.5);
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                _isCanScrollTop = NO;
                _isCanScrollBottom = YES;
            }];
        }
    } else if (_direction == kCameraMoveDirectionUp && _isCanScrollTop) {
        if (fabs(value) > 100) {
            self.titleBackgroundViewTopConstraint.constant = 64;
            self.nameLabelTopConstraint.constant = 32;
            self.iconBackgroundViewTopConstraint.constant = 0;
            self.iconBackgroundViewCenterYConstraint.constant = -(30 + CGRectGetWidth(self.nameLabel.frame) / 2);
            self.iconBackgroundView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            self.headImage.transform = CGAffineTransformMakeScale(0.5, 0.5);
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                _isCanScrollTop = NO;
                _isCanScrollBottom = YES;
            }];
        } else {
            self.titleBackgroundViewTopConstraint.constant = 250;
            self.nameLabelTopConstraint.constant = 135;
            self.iconBackgroundViewTopConstraint.constant = 45;
            self.iconBackgroundViewCenterYConstraint.constant = 0;
            self.iconBackgroundView.transform = CGAffineTransformMakeScale(1, 1);
            self.headImage.transform = CGAffineTransformMakeScale(1, 1);
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                _isCanScrollTop = YES;
                _isCanScrollBottom = NO;
            }];
        }
    }
}

#pragma mark - gestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)addChildViewControllers {
//    SJPersonalHomeViewController *personalHomeVC = [[SJPersonalHomeViewController alloc] init];
//    personalHomeVC.target_id = self.target_id;
    SJInteractViewController *interactVC = [[SJInteractViewController alloc] init];
    interactVC.target_id = self.target_id;
    
    SJPersonalOldLiveViewController *personalOldLiveVC = [[SJPersonalOldLiveViewController alloc] init];
    personalOldLiveVC.target_id = self.target_id;
    SJPersonalReferenceViewController *personalReferenceVC = [[SJPersonalReferenceViewController alloc] init];
    personalReferenceVC.target_id = self.target_id;
    SJPersonalSummaryViewController *personalSummaryVC = [[SJPersonalSummaryViewController alloc] init];
    personalSummaryVC.target_id = self.target_id;
    SJPersonalQuestionViewController *personalQuestionVC = [[SJPersonalQuestionViewController alloc] init];
    personalQuestionVC.target_id = self.target_id;
//    [self addChildViewController:personalHomeVC];
    [self addChildViewController:interactVC];
    [self addChildViewController:personalOldLiveVC];
    [self addChildViewController:personalReferenceVC];
    [self addChildViewController:personalSummaryVC];
    [self addChildViewController:personalQuestionVC];
}

- (IBAction)titleButtonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - 101;
    CGFloat offsetX = index * self.contentScrollView.frame.size.width;
    CGFloat offsetY = self.contentScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    [self.contentScrollView setContentOffset:offset animated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)threeButtonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 2001:
            // 加关注
            [self clickAddAttentionButton:button];
            break;
        case 2002: {
            // 私信
            if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
                SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
                [self.navigationController pushViewController:loginVC animated:YES];
                return;
            }
            NSString *target_id = [NSString stringWithFormat:@"%@", self.teacherInfoDic[@"user_id"]];
            if ([target_id isEqualToString:[SJUserDefaults objectForKey:kUserid]]) {
                [MBHUDHelper showWarningWithText:@"不能给自己发送私信"];
                return;
            }
            
            SJChatMessageViewController *chatMessageVC = [[SJChatMessageViewController alloc] init];
            chatMessageVC.navigationItem.title = [NSString stringWithFormat:@"%@", self.teacherInfoDic[@"nickname"]];
            chatMessageVC.target_id = target_id;
            [self.navigationController pushViewController:chatMessageVC animated:YES];
        }
            break;
        case 2003: {
            // 去问股
            SJComposeViewController *composeVC = [[SJComposeViewController alloc] init];
            composeVC.title = [NSString stringWithFormat:@"向「%@」提问",self.teacherInfoDic[@"nickname"]];
            composeVC.type = @"0";
            composeVC.targetid = self.target_id;
            [self.navigationController pushViewController:composeVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)clickAddAttentionButton:(UIButton *)button {
    if (button.selected) {
        // 已关注
        if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
            SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
            [self.navigationController pushViewController:loginVC animated:YES];
            return;
        }
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/cancelattention", HOST];
        SJToken *Token = [SJToken sharedToken];
        NSDictionary *param = @{@"token":Token.token,@"userid":Token.userid,@"time":Token.time,@"targetid":self.target_id};
        [SJhttptool POST:urlStr paramers:param success:^(id respose) {
            if ([respose[@"status"] isEqual:@"1"]) {
                self.addAttentionButton.selected = NO;
                [self.addAttentionButton setImage:[UIImage imageNamed:@"HomePage_icon1"] forState:UIControlStateNormal];
                [self.addAttentionButton setTitle:@"未关注" forState:UIControlStateNormal];
                [MBProgressHUD showSuccess:@"取消关注成功"];
            } else {
                [MBHUDHelper showWarningWithText:respose[@"data"]];
            }
        } failure:^(NSError *error) {
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
    } else {
        // 未关注
        if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
            SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
            [self.navigationController pushViewController:loginVC animated:YES];
            return;
        }
        
        SJToken *Token = [SJToken sharedToken];
        [[SJNetManager sharedNetManager] addAttentionWithToken:Token.token andUserid:Token.userid andTime:Token.time andTargetid:self.target_id withSuccessBlock:^(NSDictionary *dict) {
            if ([dict[@"status"] isEqualToString:@"1"]) {
                self.addAttentionButton.selected = YES;
                [self.addAttentionButton setImage:[UIImage imageNamed:@"guanzhu"] forState:UIControlStateNormal];
                [self.addAttentionButton setTitle:@"已关注" forState:UIControlStateNormal];
                [MBProgressHUD showSuccess:@"关注成功"];
            } else {
                [MBHUDHelper showWarningWithText:dict[@"data"]];
            }
        } andFailBlock:^(NSError *error) {
            SJLog(@"%@", error);
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x <= 0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
/**
 *  滚动结束后调用（代码导致）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSUInteger index = scrollView.contentOffset.x / self.contentScrollView.frame.size.width;
    [self.titleBackgroundView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (button.tag == index + 101) {
                button.selected = YES;
            } else {
                button.selected = NO;
            }
        }
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)obj;
            if (imageView.tag == index + 201) {
                imageView.image = [UIImage imageNamed:@"nav_line_09"];
            } else {
                imageView.image = [UIImage imageNamed:@"nav_line_11"];
            }
        }
    }];
    // 添加控制器
    UIViewController *newVC = self.childViewControllers[index];
    if (newVC.view.superview) return;
    newVC.view.frame = scrollView.bounds;
    [self.contentScrollView addSubview:newVC.view];
}
/**
 *  滚动结束（手势导致）
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
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


@end

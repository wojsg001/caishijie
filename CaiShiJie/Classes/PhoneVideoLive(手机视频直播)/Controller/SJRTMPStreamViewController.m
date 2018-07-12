//
//  SJRTMPStreamViewController.m
//  CaiShiJie
//
//  Created by user on 18/11/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRTMPStreamViewController.h"
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>
#import "TLChatBoxViewController.h"
#import "SJVideoInteractiveCell.h"
#import "SJVideoInteractiveModel.h"
#import "SDAutoLayout.h"
#import "SRWebSocket.h"
#import "SJAnimOperationManager.h"
#import "SJAnimOperation.h"
#import "SJPresentFlower.h"
#import "SJGiftModel.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import "SJVideoTeacherInfoModel.h"
#import "SJAddLiveInfoView.h"
#import <NSArray+BlocksKit.h>
#import "SJLoginViewController.h"
#import "RegexKitLite.h"
#import "SJFaceHandler.h"
#import "ZZPhotoKit.h"
#import "SJNetManager.h"
#import "SJUploadParam.h"
#import "SJProgressHUD.h"

/**
 用户信息View
 */
@interface SJRTMPUserView ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation SJRTMPUserView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" withAlpha:0.3];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews {
    _headImageView = [[UIImageView alloc] init];
    _headImageView.image = [UIImage imageNamed:@"icon_teacher"];
    _headImageView.layer.cornerRadius = 29/2;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.userInteractionEnabled = YES;
    [self addSubview:_headImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"----";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _countLabel = [[UILabel alloc] init];
    _countLabel.text = @"----";
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.font = [UIFont systemFontOfSize:10];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_countLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = YES;
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(29);
        make.left.mas_equalTo(3);
        make.centerY.mas_equalTo(self);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(7);
        make.left.equalTo(self.headImageView.mas_right).offset(7);
        make.right.mas_equalTo(-7);
        make.height.mas_equalTo(10);
    }];
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(7);
        make.right.mas_equalTo(-7);
        make.height.mas_equalTo(10);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
    
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.head_img]] placeholderImage:[UIImage imageNamed:@"icon_teacher"]];
    _titleLabel.text = _model.nickname;
    _countLabel.text = _model.total_count;
}

@end
/**
 视频流控制器
 */
@interface SJRTMPStreamViewController ()<PLMediaStreamingSessionDelegate, TLChatBoxViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, SRWebSocketDelegate>
{
    SRWebSocket *_webSocket;
    PLMediaStreamingSession *_streamingSession;
}

@property (nonatomic, strong) UIButton *chartButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *meiyanButton;
@property (nonatomic, strong) UIButton *torchButton;
@property (nonatomic, strong) UIButton *reversalButton;
@property (nonatomic, strong) SJRTMPUserView *topUserView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *presentBgView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *message_max_sn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) SJVideoTeacherInfoModel *teacherInfoModel;
@property (nonatomic, strong) NSArray *computerFaceArray;
@property (nonatomic, weak) SJAddLiveInfoView *addLiveInfoView;
@property (nonatomic, copy) NSString *streamURL;

@end

@implementation SJRTMPStreamViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (TLChatBoxViewController *)chatBoxVC {
    if (!_chatBoxVC) {
        _chatBoxVC = [[TLChatBoxViewController alloc] init];
        _chatBoxVC.delegate = self;
        [_chatBoxVC setUpChatBoxMoreButtonHidden:YES];
    }
    return _chatBoxVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupAddLiveInfoView];
    [self setupPLStreamSession];
    [self loadTeacherInfoData];
    self.computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
}

- (void)setupAddLiveInfoView {
    _topUserView = [[SJRTMPUserView alloc] init];
    _topUserView.hidden = YES;
    [self.view addSubview:_topUserView];
    [_topUserView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(35);
    }];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJPhoneLiveUI" owner:nil options:nil];
    SJAddLiveInfoView *addLiveInfoView = [nib bk_match:^BOOL(id obj) {
        return [obj isKindOfClass:[SJAddLiveInfoView class]];
    }];
    _addLiveInfoView = addLiveInfoView;
    [addLiveInfoView.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [addLiveInfoView.addImgButton addTarget:self action:@selector(addImgButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addLiveInfoView];
    [addLiveInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    // 退出按钮
    _backButton = [self creatButtonWithImage:[UIImage imageNamed:@"live_off_icon"] selectedImage:nil tag:-1];
    [self.view addSubview:_backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.right.mas_equalTo(-10);
    }];
}

- (void)loadTeacherInfoData {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/findteachervideo", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:instance.userid forKey:@"user_id"];
    [params setObject:instance.token forKey:@"token"];
    [params setObject:instance.time forKey:@"time"];
    [SJhttptool GET:urlStr paramers:params success:^(id respose) {
        SJLog(@"%@", respose[@"data"]);
        if ([respose[@"status"] integerValue]) {
            _teacherInfoModel = [SJVideoTeacherInfoModel objectWithKeyValues:respose[@"data"]];
            _message_max_sn = [NSString stringWithFormat:@"%@", respose[@"data"][@"message_max_sn"]];
            _topUserView.model = _teacherInfoModel;
            _addLiveInfoView.model = _teacherInfoModel;
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        self.addLiveInfoView.hidden = YES;
        [SJProgressHUD showNetworkErrorToView:self.view reload:^{
            [SJProgressHUD hideNetworkErrorFromView:self.view];
            [self loadTeacherInfoData];
            self.addLiveInfoView.hidden = NO;
        }];
    }];
}

#pragma mark - 设置子视图
- (void)setupSubviews {
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnClick:)];
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.numberOfTapsRequired = 1;
    [self.topView addGestureRecognizer:singleFingerOne];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-57);
    }];
    
    _chartButton = [self creatButtonWithImage:[UIImage imageNamed:@"live_down_icon1"] selectedImage:nil tag:101];
    _meiyanButton = [self creatButtonWithImage:[UIImage imageNamed:@"live_down_r1_n"] selectedImage:[UIImage imageNamed:@"live_down_r1_h"] tag:102];
    _torchButton = [self creatButtonWithImage:[UIImage imageNamed:@"live_down_r2_n"] selectedImage:[UIImage imageNamed:@"live_down_r2_h"] tag:103];
    _reversalButton = [self creatButtonWithImage:[UIImage imageNamed:@"live_down_r3_n"] selectedImage:[UIImage imageNamed:@"live_down_r3_h"] tag:104];
    _meiyanButton.selected = YES;
    _torchButton.selected = NO;
    _reversalButton.selected = NO;
    [self.view addSubview:_chartButton];
    [self.view addSubview:_meiyanButton];
    [self.view addSubview:_torchButton];
    [self.view addSubview:_reversalButton];
    [_chartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
    }];
    [_reversalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
    }];
    [_torchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.reversalButton.mas_left).offset(-15);
        make.bottom.mas_equalTo(-10);
    }];
    [_meiyanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.torchButton.mas_left).offset(-15);
        make.bottom.mas_equalTo(-10);
    }];
    
    [self.view addSubview:self.chatBoxVC.view];
    [self.chatBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
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
    [self.topView addSubview:_presentBgView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.height.mas_equalTo(125);
        make.width.mas_equalTo(250);
    }];
    [_presentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(self.tableView.mas_top).offset(-69);
        make.height.mas_equalTo(110);
    }];
    
    [self.view bringSubviewToFront:_backButton];
    _topUserView.hidden = NO;
}

- (UIButton *)creatButtonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag {
    UIButton *button = [[UIButton alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
    button.tag = tag;
    [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - 加载霹雳流信息
- (void)loadPLMediaStreamingData {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        return;
    }

    _addLiveInfoView.startButton.enabled = NO;
    
    SJToken *instance = [SJToken sharedToken];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:instance.userid forKey:@"user_id"];
    [params setObject:instance.token forKey:@"token"];
    [params setObject:instance.time forKey:@"time"];
    
    [MBProgressHUD showMessage:@"请稍后..." toView:self.view];
    if (![[_addLiveInfoView.addTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:_teacherInfoModel.user_live_title]) {
        // 如果有新标题
        [params setObject:[_addLiveInfoView.addTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"live_title"];
    }
    
    if (_addLiveInfoView.image) {
        // 如果有新封面，先上传图片
        SJUploadParam *uploadP = [[SJUploadParam alloc] init];
        uploadP.data = UIImageJPEGRepresentation(self.addLiveInfoView.image, 0.00001);
        uploadP.name = @"filedata";
        uploadP.fileName = @"image.jpeg";
        uploadP.mimeType = @"image/jpeg";
        
        [[SJNetManager sharedNetManager] uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
            //SJLog(@"%@",dict);
            if ([dict[@"status"] isEqual:@(1)]) {
                [params setObject:dict[@"data"] forKey:@"live_img"];
                [self submitData:params];
            } else {
                // 显示上传错误信息
                [MBProgressHUD hideHUDForView:self.view];
                [self showAlertWithTitle:@"温馨提示" message:dict[@"data"]];
                _addLiveInfoView.startButton.enabled = YES;
            }
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view];
            [self showAlertWithTitle:@"错误提示" message:error.localizedDescription];
            _addLiveInfoView.startButton.enabled = YES;
        }];
    } else {
        [self submitData:params];
    }
}

#pragma mark - 提交推流数据（满足后才可以推流）
- (void)submitData:(NSDictionary *)params {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/openlivevideo", HOST];
    [SJhttptool GET:urlStr paramers:params success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"status"] integerValue]) {
            NSDictionary *streamJSON = [NSJSONSerialization JSONObjectWithData:[respose[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            _streamURL = [NSString stringWithFormat:@"rtmp://%@/%@/%@?key=%@", streamJSON[@"hosts"][@"publish"][@"rtmp"], streamJSON[@"hub"], streamJSON[@"title"], streamJSON[@"publishKey"]];
            // 提交成功开始推流
            [self startSession];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self showAlertWithTitle:@"错误提示" message:error.localizedDescription];
        _addLiveInfoView.startButton.enabled = YES;
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 点击事件
- (void)startButtonPressed:(UIButton *)button {
    // 加载霹雳流信息
    [self loadPLMediaStreamingData];
}

- (void)addImgButtonPressed:(UIButton *)button {
    ZZPhotoController *photoController = [[ZZPhotoController alloc] init];
    photoController.selectPhotoOfMax = 1;
    [photoController showIn:self result:^(id responseObject) {
        NSArray *array = (NSArray *)responseObject;
        if (array.count) {
            _addLiveInfoView.image = [array objectAtIndex:0];
        }
    }];
}

- (void)actionButtonPressed:(UIButton *)button {
    switch (button.tag) {
        case -1: {
            // 关闭视频
            if (PLStreamStateConnected == _streamingSession.streamState) {
                [self showAlert];
            } else {
                [self.timer invalidate];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case 101:
            // 互动
            [self.chatBoxVC setUpChatBoxTextViewBecomeFirstResponder];
            break;
        case 102:
            // 美颜
            button.selected = !button.selected;
            [self setBeautifyOpenOrClose:button.selected];
            break;
        case 103: {
            // 闪光
            button.selected = !button.selected;
            _streamingSession.torchOn = !_streamingSession.isTorchOn;
        }
            break;
        case 104: {
            // 翻转
            button.selected = !button.selected;
            [_streamingSession toggleCamera];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 设置美颜
- (void)setBeautifyOpenOrClose:(BOOL)isOpen {
    [_streamingSession setBeautifyModeOn:isOpen];
    if (isOpen) {
        [_streamingSession setBeautify:1];
        [_streamingSession setWhiten:1];
    } else {
        [_streamingSession setBeautify:0];
        [_streamingSession setWhiten:0];
    }
}

- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否结束视频？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self stopSession];
        [self.timer invalidate];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    if ([alert valueForKey:@"attributedTitle"]) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:alert.title];
        NSDictionary *attDic = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#030303" withAlpha:1]};
        [attString addAttributes:attDic range:NSMakeRange(0, attString.length)];
        [alert setValue:attString forKey:@"attributedTitle"];
    }
    if ([cancelAction valueForKey:@"titleTextColor"]) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:cancelAction.title];
        NSDictionary *attDic = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#0861e4" withAlpha:1]};
        [attString addAttributes:attDic range:NSMakeRange(0, attString.length)];
        [cancelAction setValue:attDic forKey:@"titleTextColor"];
    }
    if ([defaultAction valueForKey:@"titleTextColor"]) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:defaultAction.title];
        NSDictionary *attDic = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#0861e4" withAlpha:1]};
        [attString addAttributes:attDic range:NSMakeRange(0, attString.length)];
        [defaultAction setValue:attDic forKey:@"titleTextColor"];
    }
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 设置推流对象
- (void)setupPLStreamSession {
    void(^permissionBlock)(void) = ^{
       
            // 视频采集配置
            PLVideoCaptureConfiguration *videoCaptureConfiguration = [[PLVideoCaptureConfiguration alloc] initWithVideoFrameRate:24 sessionPreset:AVCaptureSessionPreset640x480 previewMirrorFrontFacing:YES previewMirrorRearFacing:NO streamMirrorFrontFacing:NO streamMirrorRearFacing:NO cameraPosition:AVCaptureDevicePositionFront videoOrientation:AVCaptureVideoOrientationPortrait];
            // 音频采集配置
            PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
            // 视频编码配置
            PLVideoStreamingConfiguration *videoStreamingConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:CGSizeMake(368, 640) expectedSourceVideoFrameRate:24 videoMaxKeyframeInterval:72 averageVideoBitRate:768 * 1024 videoProfileLevel:AVVideoProfileLevelH264HighAutoLevel videoEncoderType:PLH264EncoderType_VideoToolbox];
            videoStreamingConfiguration.videoEncoderType = PLH264EncoderType_VideoToolbox;
            // 音频编码配置
            PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
            
            // 推流对象
            _streamingSession= [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
            _streamingSession.delegate = self;
            _streamingSession.dynamicFrameEnable = YES;
            [_streamingSession enableAdaptiveBitrateControlWithMinVideoBitRate:200 * 1024];
            _streamingSession.monitorNetworkStateEnable = YES; // 开启网络切换监测
            _streamingSession.connectionChangeActionCallback = ^(PLNetworkStateTransition transition) {
                switch (transition) {
                    case PLNetworkStateTransitionWWANToWiFi:
                        return YES;
                        break;
                    case PLNetworkStateTransitionWiFiToWWAN:
                        return NO;
                        break;
                        
                    default:
                        break;
                }
                return NO;
            };
            // 开启美颜
            [self setBeautifyOpenOrClose:YES];
            /**
             *  添加水印
            UIImage *waterMark = [UIImage imageNamed:@"qiniu.png"];
            [self.streamSession setWaterMarkWithImage:waterMark position:CGPointMake(50, 50)];
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                UIView *perviewView = _streamingSession.previewView;
                perviewView.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
                [self.view insertSubview:perviewView atIndex:0];
            });
    
    };
    
    void(^noAccessBlock)(void) = ^{
        SJLog(@"无法访问");
    };
    
    switch ([PLMediaStreamingSession cameraAuthorizationStatus]) {
        case PLAuthorizationStatusAuthorized:
            permissionBlock();
            break;
        case PLAuthorizationStatusNotDetermined: {
            [PLMediaStreamingSession requestCameraAccessWithCompletionHandler:^(BOOL granted) {
                granted ? permissionBlock() : noAccessBlock();
            }];
        }
            break;
            
        default:
            noAccessBlock();
            break;
    }
    // 进入前台重新推流
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reStartSession) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 进入后台停止推流
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSession) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

/**
 开始推流
 */
- (void)startSession {
    if (_streamingSession.isStreamingRunning || _streamingSession == nil) {
        return;
    }
    _addLiveInfoView.startButton.enabled = NO;
        [_streamingSession startStreamingWithPushURL:[NSURL URLWithString:_streamURL] feedback:^(PLStreamStartStateFeedback feedback) {
            switch (feedback) {
                case PLStreamStartStateSuccess:
                    SJLog(@"推流成功");
                    [self.addLiveInfoView removeFromSuperview];
                    [self setupSubviews]; // 推流成功添加子视图
                    [self reconnect]; // 推流成功开始连接socket
                    break;

                default:
                    SJLog(@"推流失败");
                    _addLiveInfoView.startButton.enabled = YES;
                    break;
            }
        }];
}

/**
 重新推流
 */
- (void)reStartSession {
    if (_streamingSession.isStreamingRunning || _streamingSession == nil || _streamURL == nil) {
        return;
    }
    
    [_streamingSession restartStreamingWithPushURL:[NSURL URLWithString:_streamURL] feedback:^(PLStreamStartStateFeedback feedback) {
            switch (feedback) {
                case PLStreamStartStateSuccess:
                    SJLog(@"重新推流成功");
                    break;
                    
                default:
                    SJLog(@"重新推流失败");
                    break;
            }}];
}

/**
 停止推流
 */
- (void)stopSession {

        [_streamingSession stopStreaming];

}

- (void)dealloc {
    SJLog(@"%s", __func__);
    [_streamingSession destroy];
    _streamingSession = nil;
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
}

#pragma mark - PLMediaStreamingSessionDelegate
/// @abstract 流状态已变更的回调
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    SJLog(@"%@", [NSString stringWithFormat:@"Stream State: %ld", (long)state]);
}

/// @abstract 因产生了某个 error 而断开时的回调，error 错误码的含义可以查看 PLTypeDefines.h 文件
- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error {
    SJLog(@"%@", [NSString stringWithFormat:@"Stream State: Error. %@", error]);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *reload = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf reStartSession]; // 重新推流
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.timer invalidate];
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:reload];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 点击事件
- (void)tapOnClick:(UITapGestureRecognizer *)tap {
    [self.chatBoxVC resignFirstResponder];
}

#pragma mark - TLChatBoxViewControllerDelegate
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height andDuration:(CGFloat)duration {
    if (height <= kTabbarHeight) {
        [self.chatBoxVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.mas_equalTo(kTabbarHeight);
        }];
        
        [UIView animateWithDuration:duration animations:^{
            self.topView.transform = CGAffineTransformIdentity;
        }];
    } else {
        [self.chatBoxVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.mas_equalTo(height);
        }];
        
        [UIView animateWithDuration:duration animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0, -(height - 57));
        }];
    }
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];

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
    NSDictionary *params = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"targetid":self.targetid,@"content":text};
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
        NSMutableArray *interactArray = [NSMutableArray array];
        for (NSDictionary *tmpDict in tmpArray) {
            if ([tmpDict[@"type"] isEqualToString:@"40"] || [tmpDict[@"type"] isEqualToString:@"1"]) {
                // 互动、送礼
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NSMutableDictionary *dictM = [tmpDict mutableCopy];
                [dictM removeObjectForKey:@"data"];
                dictM[@"data"] = jsonStr;
                [interactArray addObject:dictM];
                // 添加轮询互动
                [self addLunxunInteract:interactArray];
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
    if ([dict[@"type"] isEqual:@(40)] || [dict[@"type"] isEqual:@(1)]) {
        // 互动、送礼
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictM = [dict mutableCopy];
        [dictM removeObjectForKey:@"data"];
        dictM[@"data"] = jsonStr;
        // 添加互动
        [self addInteract:dictM];
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

#pragma mark - 添加互动
- (void)addInteract:(NSDictionary *)dict {
    SJLog(@"%@", dict);
    SJVideoInteractiveModel *model = [SJVideoInteractiveModel objectWithKeyValues:dict];
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    
    [self tableViewScrollToBottom];
    // 添加礼物动画
    [self addGiftAnimate:model];
}

#pragma mark - 添加轮询互动
- (void)addLunxunInteract:(NSArray *)array{
    NSArray *modelArray = [SJVideoInteractiveModel objectArrayWithKeyValuesArray:array];
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

@end

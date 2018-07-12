//
//  TLChatBoxViewController.m
//  iOSAppTemplate
//
//  Created by libokun on 15/10/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLChatBoxViewController.h"
#import "TLChatBox.h"
#import "TLChatBoxMoreView.h"
#import "TLChatBoxFaceView.h"
#import "macros.h"
#import "UIView+TL.h"

#import "SJInputVoiceView.h"
#import "SJSpeechRecognizerView.h"
#import <iflyMSC/IFlySpeechRecognizer.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "iflyMSC/iflyMSC.h"

@interface TLChatBoxViewController () <TLChatBoxDelegate, TLChatBoxFaceViewDelegate, TLChatBoxMoreViewDelegate, SJSpeechRecognizerViewDelegate, IFlySpeechRecognizerDelegate>

@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, strong) TLChatBox *chatBox;
@property (nonatomic, strong) TLChatBoxMoreView *chatBoxMoreView;
@property (nonatomic, strong) TLChatBoxFaceView *chatBoxFaceView;
@property (nonatomic, strong) SJInputVoiceView *inputVoiceView; // 对讲机
@property (nonatomic, strong) SJSpeechRecognizerView *speechRecognizerView; // 语音输入

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) NSString * result;

@end

@implementation TLChatBoxViewController

#pragma mark - LifeCycle
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.chatBox];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setUpChatBoxTextViewPlaceholder:(NSString *)placeholder
{
    self.chatBox.textView.placeHolder = placeholder;
}

- (void)setUpChatBoxTextViewBecomeFirstResponder
{
    [self.chatBox.textView becomeFirstResponder];
}

- (void)setUpChatBoxMoreButtonHidden:(BOOL)isHidden {
    [self.chatBox setMoreButtonHidden:isHidden];
}

- (void)hideChatBoxMoreButtomWithIndex:(NSInteger)index {
    [[self.chatBoxMoreView.subviews objectAtIndex:1].subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == index) {
            obj.hidden = YES;
        }
    }];
}

- (void)setLandscapeChatBoxFrame {
    self.chatBox.frame = CGRectMake(0, 0, HEIGHT_SCREEN, kTabbarHeight);
    [self.chatBox updateSubviewsFrame];
}

#pragma mark - Public Methods
- (BOOL) resignFirstResponder
{
    self.chatBox.textView.text = @"";
    [self.chatBox textViewDidChange:self.chatBox.textView]; // 改变textView的高度
    
    if (self.chatBox.status != TLChatBoxStatusNothing && self.chatBox.status != TLChatBoxStatusShowVoice) {
        [self.chatBox resignFirstResponder];
        self.chatBox.status = (self.chatBox.status == TLChatBoxStatusShowVoice ? self.chatBox.status : TLChatBoxStatusNothing);
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
            
            [UIView animateWithDuration:0.3 animations:^{
                [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight andDuration:0.3];
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
                [self.chatBoxMoreView removeFromSuperview];
                [self.speechRecognizerView removeFromSuperview];
                self.speechRecognizerView = nil;
            }];
        }
    }
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    
    return [super resignFirstResponder];
}

#pragma mark - TLChatBoxDelegate
- (void) chatBox:(TLChatBox *)chatBox sendTextMessage:(NSString *)textMessage
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController: sendMessage:)]) {
        [_delegate chatBoxViewController:self sendMessage:textMessage];
    }
}

- (void)chatBox:(TLChatBox *)chatBox changeChatBoxHeight:(CGFloat)height
{
    self.chatBoxFaceView.originY = height;
    self.chatBoxMoreView.originY = height;
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
        float h = (self.chatBox.status == TLChatBoxStatusShowFace ? HEIGHT_CHATBOXVIEW : self.keyboardFrame.size.height ) + height;
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: h andDuration:0.3];
    }
}

- (void) chatBox:(TLChatBox *)chatBox changeStatusForm:(TLChatBoxStatus)fromStatus to:(TLChatBoxStatus)toStatus
{
    if ([_iFlySpeechRecognizer isListening])
    {
        // 结束识别
        [self endRecognizer];
    }
    
    if (toStatus == TLChatBoxStatusShowKeyboard) {      // 显示键盘
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatBoxFaceView removeFromSuperview];
            [self.chatBoxMoreView removeFromSuperview];
            [self.speechRecognizerView removeFromSuperview];
            self.speechRecognizerView = nil;
        });
        return;
    }
    else if (toStatus == TLChatBoxStatusShowFace) {     // 显示表情面板
        if (fromStatus == TLChatBoxStatusShowVoice || fromStatus == TLChatBoxStatusNothing) {
            [self.chatBoxFaceView setOriginY:self.chatBox.curHeight];
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW andDuration:0.3];
                }
            }];
        }
        else {
            // 表情高度变化
            self.chatBoxFaceView.originY = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxFaceView.originY = self.chatBox.curHeight;
            } completion:^(BOOL finished) {
                [self.chatBoxMoreView removeFromSuperview];
                [self.speechRecognizerView removeFromSuperview];
                self.speechRecognizerView = nil;
            }];
            // 整个界面高度变化
            if (fromStatus != TLChatBoxStatusShowMore) {
                [UIView animateWithDuration:0.3 animations:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
                        [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW andDuration:0.3];
                    }
                }];
            }
        }
    }
    else if (toStatus == TLChatBoxStatusShowMore) {     // 显示更多面板
        if (fromStatus == TLChatBoxStatusShowVoice || fromStatus == TLChatBoxStatusNothing) {
            [self.chatBoxMoreView setOriginY:self.chatBox.curHeight];
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
                    [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW andDuration:0.3];
                }
            }];
        }
        else {
            self.chatBoxMoreView.originY = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxMoreView.originY = self.chatBox.curHeight;
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
                [self.speechRecognizerView removeFromSuperview];
                self.speechRecognizerView = nil;
            }];
            
            if (fromStatus != TLChatBoxStatusShowFace) {
                [UIView animateWithDuration:0.3 animations:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
                        [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW andDuration:0.3];
                    }
                }];
            }
        }
    }
}

#pragma mark - TLChatBoxFaceViewDelegate
- (void) chatBoxFaceViewDidSelectedFace:(TLFace *)face type:(TLFaceType)type
{
    if (type == TLFaceTypeEmoji) {
        [self.chatBox addEmojiFace:face];
    }
}

- (void) chatBoxFaceViewDeleteButtonDown
{
    [self.chatBox deleteButtonDown];
}

- (void) chatBoxFaceViewSendButtonDown
{
    [self.chatBox sendCurrentMessage];
}

#pragma mark - TLChatBoxMoreViewDelegate 代理方法
- (void) chatBoxMoreView:(TLChatBoxMoreView *)chatBoxMoreView didSelectItem:(TLChatBoxItem)itemType
{
    if (itemType == TLChatBoxItemAlbum) {
        // 相册
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didSelectItem:)]) {
            [self.delegate chatBoxViewController:self didSelectItem:TLChatBoxItemAlbum];
        }
    } else if (itemType == TLChatBoxItemCamera) {
        // 拍摄
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didSelectItem:)]) {
                [self.delegate chatBoxViewController:self didSelectItem:TLChatBoxItemCamera];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"当前设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } else if ((int)itemType == 2) {
        self.speechRecognizerView.originY = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
        [self.view addSubview:self.speechRecognizerView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.speechRecognizerView.originY = self.chatBox.curHeight;
        } completion:^(BOOL finished) {
            self.chatBoxMoreView.transform = CGAffineTransformIdentity;
            [self.chatBoxMoreView removeFromSuperview];
            // 开启识别
            [self startRecognizer];
        }];
    } else if ((int)itemType == 3) {
        // 钱包
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didSelectItem:)]) {
            [self.delegate chatBoxViewController:self didSelectItem:3];
        }
    }
    
//    // 实时对讲机
//    if ((int)itemType == 2)
//    {
//        [self.view addSubview:self.inputVoiceView];
//        
//        [UIView animateWithDuration:0.3 animations:^{
//            
//            self.inputVoiceView.transform = CGAffineTransformMakeTranslation(0, - 180);
//            
//        } completion:^(BOOL finished) {
//            
//            self.chatBoxMoreView.transform = CGAffineTransformIdentity;
//            [self.chatBoxMoreView removeFromSuperview];
//            
//        }];
//    }
}

#pragma mark - Private Methods
- (void)keyboardWillHide:(NSNotification *)notification{
    CGFloat durtion = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.keyboardFrame = CGRectZero;
    if (_chatBox.status == TLChatBoxStatusShowFace || _chatBox.status == TLChatBoxStatusShowMore) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
        [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight andDuration:durtion];
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)notification{
    CGFloat durtion = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_chatBox.status == TLChatBoxStatusShowKeyboard && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    else if ((_chatBox.status == TLChatBoxStatusShowFace || _chatBox.status == TLChatBoxStatusShowMore) && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:andDuration:)]) {
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: self.keyboardFrame.size.height + self.chatBox.curHeight andDuration:durtion];
    }
}

#pragma mark - Getter
- (TLChatBox *) chatBox
{
    if (_chatBox == nil) {
        _chatBox = [[TLChatBox alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, kTabbarHeight)];
        [_chatBox setDelegate:self];
    }
    return _chatBox;
}

- (TLChatBoxMoreView *) chatBoxMoreView
{
    if (_chatBoxMoreView == nil) {
        _chatBoxMoreView = [[TLChatBoxMoreView alloc] initWithFrame:CGRectMake(0, kTabbarHeight, WIDTH_SCREEN, HEIGHT_CHATBOXVIEW)];
        [_chatBoxMoreView setDelegate:self];
        
        TLChatBoxMoreItem *photosItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"照片" imageName:@"sharemore_pic"];
        TLChatBoxMoreItem *takePictureItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"拍摄" imageName:@"sharemore_video"];
//        TLChatBoxMoreItem *interphoneItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"实时对讲机" imageName:@"sharemore_wxtalk" ];
        TLChatBoxMoreItem *voiceItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"语音输入" imageName:@"sharemore_voiceinput"];
        TLChatBoxMoreItem *monerItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"钱包" imageName:@"live_money"];
        
        [_chatBoxMoreView setItems:[[NSMutableArray alloc] initWithObjects:photosItem, takePictureItem, voiceItem, monerItem, nil]];
    }
    return _chatBoxMoreView;
}

- (TLChatBoxFaceView *) chatBoxFaceView
{
    if (_chatBoxFaceView == nil) {
        _chatBoxFaceView = [[TLChatBoxFaceView alloc] initWithFrame:CGRectMake(0, kTabbarHeight, WIDTH_SCREEN, HEIGHT_CHATBOXVIEW)];
        [_chatBoxFaceView setDelegate:self];
    }
    return _chatBoxFaceView;
}

// 对讲机
- (SJInputVoiceView *)inputVoiceView
{
    if (_inputVoiceView == nil)
    {
        _inputVoiceView = [[NSBundle mainBundle] loadNibNamed:@"SJInputVoiceView" owner:nil options:nil].lastObject;
        _inputVoiceView.frame = CGRectMake(0, kTabbarHeight, WIDTH_SCREEN, 180);
    }
    return _inputVoiceView;
}

// 语音输入
- (SJSpeechRecognizerView *)speechRecognizerView
{
    if (_speechRecognizerView == nil)
    {
        _speechRecognizerView = [[NSBundle mainBundle] loadNibNamed:@"SJSpeechRecognizerView" owner:nil options:nil].lastObject;
        _speechRecognizerView.frame = CGRectMake(0, kTabbarHeight, WIDTH_SCREEN, 180);
        _speechRecognizerView.delegate = self;
    }
    return _speechRecognizerView;
}

#pragma mark - SJSpeechRecognizerViewDelegate 代理方法
- (void)startOrEndSpeechRecognizer:(BOOL)isEnd
{
    if (isEnd == YES)
    {
        //NSLog(@"结束识别");
        if ([_iFlySpeechRecognizer isListening])
        {
            // 结束识别
            [self endRecognizer];
        }
        else
        {
            // 开启识别
            [self startRecognizer];
        }
    }
    else
    {
        //NSLog(@"开始识别");
        // 开启识别
        [self startRecognizer];
    }
}

/**
 启动听写
 *****/
- (void)startRecognizer
{
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //[self.chatBox.textView setText:@""];
        
        if(_iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret) {
            NSLog(@"启动成功！");
        }else{
            NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
        }
    }
}

/**
 停止录音
 *****/
- (void)endRecognizer
{
    [_iFlySpeechRecognizer stopListening];
    //[_textField resignFirstResponder];
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    NSLog(@"%@",vol);
    
    if (volume == 0)
    {
        [self.speechRecognizerView setUpStartOrEndButtonWithImage:[UIImage imageNamed:@"yuyin_h1"]];
    }
    else
    {
        [self.speechRecognizerView setUpStartOrEndButtonWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"yuyin_h%d",volume/6 == 5 ? 5 : volume/6 + 1]]];
    }
    
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
    
    NSLog(@"正在录音");
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    
    NSLog(@"停止录音");
    
    [self.speechRecognizerView setUpStartOrEndButtonWithImage:[UIImage imageNamed:@"yuyin_n"]];
}

/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        
        if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
            } else {
                text = @"识别成功";
            }
        } else {
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            NSLog(@"%@",text);
        }
        
        NSLog(@"%@",text);
        
    }else {
        
        NSLog(@"识别结束");
        
        NSLog(@"errorCode:%d",[error errorCode]);
    }
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    _result =[NSString stringWithFormat:@"%@%@", self.chatBox.textView.text,resultString];
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    self.chatBox.textView.text = [NSString stringWithFormat:@"%@%@", self.chatBox.textView.text,resultFromJson];
    
    if (isLast){
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,self.chatBox.textView.text);
}

@end

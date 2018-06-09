//
//  SJInputVoiceView.m
//  CaiShiJie
//
//  Created by user on 16/2/24.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJInputVoiceView.h"
#import "macros.h"
#import "D3RecordButton.h"
#import "RecordHUD.h"

#define RGB(__r, __g, __b)  [UIColor colorWithRed:(1.0*(__r)/255)\
green:(1.0*(__g)/255)\
blue:(1.0*(__b)/255)\
alpha:1.0]

@interface SJInputVoiceView ()<D3RecordDelegate>
{
    AVAudioPlayer *player;
}

@property (weak, nonatomic) IBOutlet D3RecordButton *InputVoiceBtn;
@property (nonatomic, strong) UIView *topLine;

@end

@implementation SJInputVoiceView

- (UIView *) topLine
{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 0.5)];
        [_topLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
    }
    return _topLine;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.topLine];
    [self.InputVoiceBtn initRecord:self maxtime:10 title:@"松开按钮取消录音"];
    
    self.InputVoiceBtn.layer.borderWidth = 1.0f;
    self.InputVoiceBtn.layer.borderColor = RGB(188, 188, 188).CGColor;
    
    self.InputVoiceBtn.layer.cornerRadius = 5.0f;
    self.InputVoiceBtn.layer.masksToBounds = YES;
    
    [self.InputVoiceBtn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
}
#pragma mark - D3RecordDelegate 代理方法
-(void)endRecord:(NSData *)voiceData{
    NSError *error;

    player = [[AVAudioPlayer alloc]initWithData:voiceData error:&error];
    NSLog(@"%@",error);
    player.volume = 1.0f;
    [player play];
    NSLog(@"yesssssssssss..........%f",player.duration);
}


@end

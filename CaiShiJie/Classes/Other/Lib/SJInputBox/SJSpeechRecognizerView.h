//
//  SJSpeechRecognizerView.h
//  CaiShiJie
//
//  Created by user on 16/3/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJSpeechRecognizerViewDelegate <NSObject>

- (void)startOrEndSpeechRecognizer:(BOOL)isEnd; // 开始或者结束识别

@end

@interface SJSpeechRecognizerView : UIView

@property (nonatomic, weak) id<SJSpeechRecognizerViewDelegate>delegate;

- (void)setUpStartOrEndButtonWithImage:(UIImage *)img;

@end

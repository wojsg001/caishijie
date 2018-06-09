//
//  TLChatBoxViewController.h
//  iOSAppTemplate
//
//  Created by libokun on 15/10/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLChatBoxViewController;
@protocol TLChatBoxViewControllerDelegate <NSObject>
@optional
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height andDuration:(CGFloat)duration;
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message;
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didSelectItem:(NSInteger)itemType;
@end

@interface TLChatBoxViewController : UIViewController

@property (nonatomic, weak) id<TLChatBoxViewControllerDelegate>delegate;

/**
 设置输入框占位符

 @param placeholder 占位符字符串
 */
- (void)setUpChatBoxTextViewPlaceholder:(NSString *)placeholder;

/**
 让输入框成为第一响应者
 */
- (void)setUpChatBoxTextViewBecomeFirstResponder;

/**
 隐藏输入框中的更多按钮

 @param isHidden 是否隐藏
 */
- (void)setUpChatBoxMoreButtonHidden:(BOOL)isHidden;

/**
 横屏时更新输入框frame
 */
- (void)setLandscapeChatBoxFrame;

/**
 隐藏更多界面中的某个item

 @param index item所在位置
 */
- (void)hideChatBoxMoreButtomWithIndex:(NSInteger)index;

@end

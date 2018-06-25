//
//  SJMyIssueMessageFrame.h
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJMyIssueMessage,TYTextContainer;
@interface SJMyIssueMessageFrame : NSObject

@property (strong, nonatomic) TYTextContainer *textContainer;
@property (strong, nonatomic) NSArray *emotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *fontArray;//字体数组
@property (strong, nonatomic) NSArray *urlArray;//网址数组
@property (strong, nonatomic) NSArray *stockArray;//股票数组

@property (nonatomic,assign) CGRect iconF;
@property (nonatomic,assign) CGRect timeF;
@property (nonatomic,assign) CGRect contentF;
@property (nonatomic,assign) CGRect bgBtnF;

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,assign) CGFloat contentHeight;//本身内容高度
@property (nonatomic,strong) SJMyIssueMessage *message;

@property (nonatomic,assign) BOOL isRefresh;
@property (nonatomic,copy) void(^refreshRowData)(SJMyIssueMessageFrame *messageF);

@end

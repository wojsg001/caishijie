//
//  SJUserAnswerFrame.h
//  CaiShiJie
//
//  Created by user on 16/1/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJUserAnswerModel,TYTextContainer;
@interface SJUserAnswerFrame : NSObject

@property (nonatomic, strong) TYTextContainer *textContainer;

@property(strong, nonatomic) NSArray *emotionArray;//表情数组
@property(strong, nonatomic) NSArray *fontArray;//字体数组
@property(strong, nonatomic) NSArray *urlArray;//网址数组
@property(strong, nonatomic) NSArray *stockArray;//股票数组

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect levelF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect answerF;
@property (nonatomic, assign) CGRect line1ViewF;

@property (nonatomic, assign) CGFloat cellH;
@property (nonatomic, assign) float contentHeight;//本身内容高度
@property (nonatomic, strong) SJUserAnswerModel *answerModel;

@end

//
//  SJInteractionMessageFrame.h
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJMyInteractionMessage,TYTextContainer;
@interface SJMyInteractionMessageFrame : NSObject
// 内容
@property (strong, nonatomic) TYTextContainer *interactTextContainer;
@property (strong, nonatomic) NSArray *interactEmotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *interactFontArray;//字体数组
@property (strong, nonatomic) NSArray *interactUrlArray;//网址数组
@property (strong, nonatomic) NSArray *interactStockArray;//股票数组
// 回复
@property (strong, nonatomic) TYTextContainer *originalTextContainer;
@property (strong, nonatomic) NSArray *originalEmotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *originalFontArray;//字体数组
@property (strong, nonatomic) NSArray *originalUrlArray;//网址数组
@property (strong, nonatomic) NSArray *originalStockArray;//股票数组

@property (nonatomic,assign) CGRect iconF;
@property (nonatomic,assign) CGRect nameF;
@property (nonatomic,assign) CGRect timeF;
@property (nonatomic,assign) CGRect contentF;// 内容
@property (nonatomic,assign) CGRect textF;// 回复
@property (nonatomic,assign) CGRect bgBtnF;// 背景

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,assign) CGFloat interactContentHeight;//本身内容高度
@property (nonatomic,assign) CGFloat originalContentHeight;//本身内容高度
@property (nonatomic,strong) SJMyInteractionMessage *message;

@end

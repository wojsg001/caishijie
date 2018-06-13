//
//  SJQuestionFrame.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJQuestionModel, TYTextContainer;
@interface SJQuestionFrame : NSObject

@property (nonatomic, strong) TYTextContainer *contentTextContainer;

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect contentF;
@property (nonatomic, assign) CGRect answerBtnF;
@property (nonatomic, assign) CGRect bottomViewF;

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,strong) SJQuestionModel *questionModel;

@end

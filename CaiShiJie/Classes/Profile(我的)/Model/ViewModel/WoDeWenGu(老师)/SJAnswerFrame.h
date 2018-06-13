//
//  SJAnswerFrame.h
//  CaiShiJie
//
//  Created by user on 16/1/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJAnswerModel, TYTextContainer;
@interface SJAnswerFrame : NSObject

@property (nonatomic, strong) TYTextContainer *contentTextContainer;
@property (nonatomic, strong) TYTextContainer *answerTextContainer;

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect countF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect contentF;
@property (nonatomic, assign) CGRect line1ViewF;
@property (nonatomic, assign) CGRect answerF;
@property (nonatomic, assign) CGRect bottomViewF;

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,strong) SJAnswerModel *answerModel;

@end

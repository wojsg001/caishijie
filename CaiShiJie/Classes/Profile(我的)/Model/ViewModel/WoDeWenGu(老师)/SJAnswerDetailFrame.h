//
//  SJAnswerDetailFrame.h
//  CaiShiJie
//
//  Created by user on 18/7/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJAnswerdetailModel, TYTextContainer;
@interface SJAnswerDetailFrame : NSObject

@property (nonatomic, strong) TYTextContainer *contentTextContainer;

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect honorF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect answerF;

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,strong) SJAnswerdetailModel *answerModel;

@end

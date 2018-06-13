//
//  SJQuestionDetailFrame.h
//  CaiShiJie
//
//  Created by user on 16/7/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJDetailModel, TYTextContainer;
@interface SJQuestionDetailFrame : NSObject

@property (nonatomic, strong) TYTextContainer *contentTextContainer;

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect countF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect contentF;

@property (nonatomic, assign) CGFloat cellH;
@property (nonatomic, strong) SJDetailModel *questionDetailModel;

@end

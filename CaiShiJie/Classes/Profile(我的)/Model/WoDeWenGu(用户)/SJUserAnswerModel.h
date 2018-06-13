//
//  SJUserAnswerModel.h
//  CaiShiJie
//
//  Created by user on 16/1/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJUserAnswerDetail;
@interface SJUserAnswerModel : NSObject

@property (nonatomic, copy) NSString *data;

@property (nonatomic, strong) SJUserAnswerDetail *answerDetail;

@end

//
//  SJUserQuestionModel.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJUserQuestionDetail;
@interface SJUserQuestionModel : NSObject

@property (nonatomic, copy) NSString *answer_count;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *question_id;
@property (nonatomic, copy) NSString *sn;

@property (nonatomic, strong) SJUserQuestionDetail *questionDetail;

@end

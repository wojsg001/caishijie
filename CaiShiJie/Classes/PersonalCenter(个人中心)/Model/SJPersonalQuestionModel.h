//
//  SJPersonalQuestionModel.h
//  CaiShiJie
//
//  Created by user on 16/10/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface SJPersonalQuestionModel : NSObject<MJKeyValue>

@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *answer_count;
@property (nonatomic, copy) NSString *honnor;

@property (nonatomic, strong) SJPersonalQuestionModel *answer;

@end

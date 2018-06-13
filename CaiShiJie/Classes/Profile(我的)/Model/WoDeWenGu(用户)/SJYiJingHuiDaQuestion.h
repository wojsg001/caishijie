//
//  SJYiJingHuiDaQuestion.h
//  CaiShiJie
//
//  Created by user on 16/1/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJYiJingHuiDaAnswer;
@interface SJYiJingHuiDaQuestion : NSObject

@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSDictionary *answer;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *created_at;

@property (nonatomic ,strong) SJYiJingHuiDaAnswer *YiJingHuiDaAnswerModel;

@end

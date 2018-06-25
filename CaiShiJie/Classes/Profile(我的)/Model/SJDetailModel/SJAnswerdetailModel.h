//
//  SJAnswerdetailModel.h
//  CaiShiJie
//
//  Created by user on 18/1/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJAnswerdetailModel : NSObject

@property (nonatomic,copy) NSString *answer_count;
@property (nonatomic,copy) NSString *created_at;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *head_img;
@property (nonatomic,copy) NSString *nickname;
@property (nonatomic,copy) NSString *level;

- (instancetype)initwithdic:(NSDictionary *)dic;
+ (instancetype)modelwithdic:(NSDictionary *)dict;

@end

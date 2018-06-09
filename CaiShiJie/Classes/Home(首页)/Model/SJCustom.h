//
//  SJCustom.h
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJCustom : NSObject

@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *fans;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *like;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *question_count;
@property (nonatomic, copy) NSString *honor;

+ (instancetype)customWithDict:(NSDictionary *)dict;

@end

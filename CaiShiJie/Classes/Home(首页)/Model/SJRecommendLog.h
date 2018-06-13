//
//  SJRecommendLog.h
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJRecommendLog : NSObject

@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *clicks;
@property (nonatomic, copy) NSString *honor;
@property (nonatomic, copy) NSString *article_id;

+ (instancetype)recommendLogWithDict:(NSDictionary *)dict;

@end

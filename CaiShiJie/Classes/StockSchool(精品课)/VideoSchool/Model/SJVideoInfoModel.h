//
//  SJVideoInfoModel.h
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJVideoInfoModel : NSObject

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *course_id;
@property (nonatomic, copy) NSString *course_name;
@property (nonatomic, copy) NSString *course_type;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *cur_period_id; //课时id
@property (nonatomic, copy) NSString *end_at;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *introduce;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *start_at;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *clickCount;

@end

//
//  SJDetailModel.h
//  CaiShiJie
//
//  Created by user on 16/1/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJDetailModel : NSObject

@property (nonatomic, copy) NSString *answer_count;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;

- (instancetype)initwithdic:(NSDictionary *)dic;
+ (instancetype)detailwith:(NSDictionary *)dict;

@end

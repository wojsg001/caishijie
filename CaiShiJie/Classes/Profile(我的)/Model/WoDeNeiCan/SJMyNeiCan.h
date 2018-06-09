//
//  SJMyNeiCan.h
//  CaiShiJie
//
//  Created by user on 15/12/31.
//  Copyright © 2015年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJMyNeiCan : NSObject
/**
 *  创建时间
 */
@property (nonatomic, copy) NSString *created_at;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  简介
 */
@property (nonatomic, copy) NSString *summary;
/**
 *  内参id
 */
@property (nonatomic,copy)NSString *reference_id;
/**
 *  开始时间
 */
@property (nonatomic, copy) NSString *start_at;
/**
 *  结束时间
 */
@property (nonatomic, copy) NSString *end_at;
/**
 *  内参封面图
 */
@property (nonatomic, copy) NSString *reference_img;
/**
 *  价格
 */
@property (nonatomic, copy) NSString *price;
/**
 *  订阅人数
 */
@property (nonatomic, copy) NSString *pay_count;
/**
 *  内参状态
 */
@property (nonatomic, copy) NSString *status;
/**
 *  购买内参时间
 */
@property (nonatomic, copy) NSString *pay_created_at;
/**
 *  播主userid
 */
@property (nonatomic, copy) NSString *user_id;
/**
 *  是否购买
 */
@property (nonatomic, copy) NSString *isPay;
/**
 *  用户头像
 */
@property (nonatomic, copy) NSString *head_img;
/**
    用户名
 */
@property (nonatomic, copy) NSString *nickname;
/**
 *  当前用户是否购买（内参详情）
 */
@property (nonatomic, copy) NSString *ispay;

@end

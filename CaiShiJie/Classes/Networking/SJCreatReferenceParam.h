//
//  SJCreatReferenceParam.h
//  CaiShiJie
//
//  Created by user on 16/4/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJCreatReferenceParam : NSObject

/*
 token：用户秘钥
 userid :用户Id
 time:生成加密的时间戳
 title :内参标题
 summary ：内参简介
 price ：内参价格
 startat ：内参服务开始时间
 endat ：内参服务结束时间
 img ：内参封面图
 */
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *startat;
@property (nonatomic, copy) NSString *endat;

@end

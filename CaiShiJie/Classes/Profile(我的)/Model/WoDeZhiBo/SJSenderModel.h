//
//  SJSenderModel.h
//  CaiShiJie
//
//  Created by user on 18/3/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJGiftGeterModel;
@interface SJSenderModel : NSObject

@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *item_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *item_name;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *item_count;
@property (nonatomic, strong) NSDictionary *seller;
@property (nonatomic, copy) NSString *hongbao;

@property (nonatomic, strong) SJGiftGeterModel *giftGeterModel;

@end

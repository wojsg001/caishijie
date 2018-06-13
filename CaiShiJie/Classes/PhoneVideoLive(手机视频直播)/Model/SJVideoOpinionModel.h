//
//  SJVideoOpinionModel.h
//  CaiShiJie
//
//  Created by user on 16/7/27.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJOpinionModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *nickname;

@end

@interface SJVideoOpinionModel : NSObject

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *target_id;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *data;

@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;

@property (nonatomic, strong) SJOpinionModel *model;

@end

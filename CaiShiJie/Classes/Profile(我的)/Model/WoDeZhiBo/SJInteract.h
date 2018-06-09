//
//  SJInteract.h
//  CaiShiJie
//
//  Created by user on 16/1/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJOriginal;
@interface SJInteract : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, strong) NSDictionary *original;// 回复

@property (nonatomic, strong) SJOriginal *originalM;

@end

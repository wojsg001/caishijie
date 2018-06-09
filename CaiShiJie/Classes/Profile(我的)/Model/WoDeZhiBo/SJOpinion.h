//
//  SJOpinion.h
//  CaiShiJie
//
//  Created by user on 16/1/20.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJOpinion : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;

@end

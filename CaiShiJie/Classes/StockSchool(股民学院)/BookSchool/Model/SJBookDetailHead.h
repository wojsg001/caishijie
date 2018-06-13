//
//  SJBookDetailHead.h
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJBookDetailHead : NSObject

@property (nonatomic, copy) NSString *cover_img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *publication_at;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, assign) BOOL isExpand;

@end

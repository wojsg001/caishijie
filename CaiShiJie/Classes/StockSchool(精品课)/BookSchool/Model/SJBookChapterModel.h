//
//  SJBookChapterModel.h
//  CaiShiJie
//
//  Created by user on 18/4/20.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJBookChapterModel : NSObject

@property (nonatomic, copy) NSString *chapter_id;
@property (nonatomic, copy) NSString *click_count;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, copy) NSString *title;

@end

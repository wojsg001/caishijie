//
//  SJBookSectionModel.h
//  CaiShiJie
//
//  Created by user on 18/4/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJBookSectionModel : NSObject

@property (nonatomic, copy) NSString *chapter_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isCanClick;

@end

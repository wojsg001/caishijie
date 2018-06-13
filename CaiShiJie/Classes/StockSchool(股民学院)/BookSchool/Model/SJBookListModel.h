//
//  SJBookListModel.h
//  CaiShiJie
//
//  Created by user on 16/4/20.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJBookListModel : NSObject

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *book_id;
@property (nonatomic, copy) NSString *click_count;
@property (nonatomic, copy) NSString *cover_img;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *original;
@property (nonatomic, copy) NSString *orders;
@property (nonatomic, copy) NSString *press;
@property (nonatomic, copy) NSString *publication_at;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *user_id;

@end

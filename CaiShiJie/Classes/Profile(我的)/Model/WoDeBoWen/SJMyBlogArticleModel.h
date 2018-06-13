//
//  SJMyBlogArticleModel.h
//  CaiShiJie
//
//  Created by user on 16/4/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJMyBlogArticleModel : NSObject

@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *clicks;
@property (nonatomic, copy) NSString *honor;
@property (nonatomic, copy) NSString *article_id;
@property (nonatomic, copy) NSString *permissions; // 公开或私密
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *label;

@end

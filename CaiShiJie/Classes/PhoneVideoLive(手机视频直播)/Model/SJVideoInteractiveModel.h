//
//  SJVideoInteractiveModel.h
//  CaiShiJie
//
//  Created by user on 16/11/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJInteractiveDataModel : NSObject

@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *item_img;
@property (nonatomic, copy) NSString *item_name;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *item_count;
@property (nonatomic, copy) NSString *content;

@end

@interface SJVideoInteractiveModel : NSObject

@property (strong, nonatomic) NSMutableAttributedString *attributedString;
@property (strong, nonatomic) NSArray *emotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *stockArray;//股票数组

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *target_id;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSString *text; // 处理的字符串

@property (nonatomic, strong) SJInteractiveDataModel *model;

@end

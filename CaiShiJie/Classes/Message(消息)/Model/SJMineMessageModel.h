//
//  SJMineMessageModel.h
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJMineMessageModel : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, strong) NSMutableAttributedString *contentAttributedString;

@end

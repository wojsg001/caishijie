//
//  SJGiftModel.h
//  CaiShiJie
//
//  Created by user on 16/3/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJGiftModel : NSObject

@property (nonatomic, copy) NSString *gift_id;
@property (nonatomic, copy) NSString *gift_name;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, assign) NSInteger giftCount;

@end

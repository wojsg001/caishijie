//
//  SJInteractionMessage.h
//  CaiShiJie
//
//  Created by user on 18/1/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJInteract;
@interface SJMyInteractionMessage : NSObject

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *target_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *data;

@property (nonatomic, strong) SJInteract *interactM;

@end

//
//  SJChatRoomFollowModel
//  CaiShiJie
//
//  Created by user on 18/5/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJChatRoomFollowModel : NSObject

@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *live_id;
@property (nonatomic, copy) NSString *total_count;// 人气
@property (nonatomic, copy) NSString *opinion_count;// 观点
@property (nonatomic, copy) NSString *comment_count;// 互动

@end

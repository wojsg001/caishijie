//
//  SJVideoTeacherInfoModel.h
//  CaiShiJie
//
//  Created by user on 18/11/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJVideoTeacherInfoModel : NSObject

@property (nonatomic, copy) NSString *comment_count;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *identity;
/**
 是否关注, 0-未关注, 1-已关注
 */
@property (nonatomic, copy) NSString *isFocus;
@property (nonatomic, copy) NSString *live_id;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *opinion_count;
/**
 文字视频状态, 0-视频中, 1-未开始视频
 */
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *total_count;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *video_img;
/**
 视频平台类型，1-PC, 2-iOS
 */
@property (nonatomic, copy) NSString *video_type;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *user_summary;
@property (nonatomic, copy) NSString *user_live_img;
@property (nonatomic, copy) NSString *user_live_title;
/**
 视频视频状态，1-开播，2-未开播
 */
@property (nonatomic, copy) NSString *live_status;

@end

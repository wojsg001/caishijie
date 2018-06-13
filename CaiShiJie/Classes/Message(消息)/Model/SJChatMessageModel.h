//
//  SJChatMessageModel.h
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SJMessageTypeSendToOthers,
    SJMessageTypeSendToMe
} SJMessageType;

@class TYTextContainer;
@interface SJChatMessageContentModel : NSObject

@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) BOOL isShowTime;

@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, copy) void(^refreshRowData)(SJChatMessageContentModel *model);
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;

@property (strong, nonatomic) TYTextContainer *textContainer;
@property (strong, nonatomic) NSArray *emotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *fontArray;//字体数组
@property (strong, nonatomic) NSArray *urlArray;//网址数组
@property (strong, nonatomic) NSArray *stockArray;//股票数组
@property (assign, nonatomic) CGFloat textWidth;

@end


@interface SJChatMessageModel : NSObject

@property (nonatomic, assign) SJMessageType messageType;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *target_id;
@property (nonatomic, copy) NSString *data;

@property (nonatomic, strong) SJChatMessageContentModel *model;

@end

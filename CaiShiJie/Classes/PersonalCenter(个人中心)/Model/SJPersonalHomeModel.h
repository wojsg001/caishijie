//
//  SJPersonalHomeModel.h
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYTextContainer.h"

/**
 *  说说和观点模型
 */
@interface SJPersonalHomeOpinionModel : NSObject
/**
 *  说说图片
 */
@property (nonatomic, copy) NSString *imgs;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *nickname;

@property (strong, nonatomic) TYTextContainer *textContainer;
@property (strong, nonatomic) NSArray *emotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *fontArray;//字体数组
@property (strong, nonatomic) NSArray *urlArray;//网址数组
@property (strong, nonatomic) NSArray *stockArray;//股票数组

@end

/**
 *  文章模型
 */
@interface SJPersonalHomeArticleModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *head_img;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created_at;

@property (strong, nonatomic) TYTextContainer *textContainer;
@property (strong, nonatomic) NSArray *emotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *fontArray;//字体数组
@property (strong, nonatomic) NSArray *urlArray;//网址数组
@property (strong, nonatomic) NSArray *stockArray;//股票数组

@end


@interface SJPersonalHomeModel : NSObject
/**
 *  收藏
 */
@property (nonatomic, copy) NSString *collection;
/**
 *  评论
 */
@property (nonatomic, copy) NSString *comment;
/**
 *  时间
 */
@property (nonatomic, copy) NSString *created_at;
/**
 *  转发
 */
@property (nonatomic, copy) NSString *forward;
/**
 *  赞
 */
@property (nonatomic, copy) NSString *praise;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *types;
@property (nonatomic, copy) NSString *item_type;
@property (nonatomic, copy) NSString *item_data;
/**
 *  观点item_type=21 说说item_type=23 问股item_type=30
 */
@property (nonatomic, strong) SJPersonalHomeOpinionModel *opinionModel;
/**
 *  文章item_type=22
 */
@property (nonatomic, strong) SJPersonalHomeArticleModel *articleModel;

@end

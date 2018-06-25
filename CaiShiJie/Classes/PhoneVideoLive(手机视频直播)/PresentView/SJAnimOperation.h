//
//  SJAnimOperation.h
//  CaiShiJie
//
//  Created by user on 18/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJPresentFlower, SJGiftModel;
@interface SJAnimOperation : NSOperation

@property (nonatomic, strong) SJPresentFlower *presentView;
@property (nonatomic, strong) UIView *listView;
@property (nonatomic, strong) SJGiftModel *model;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *userID; // 用户唯一标识

/**
 回调参数

 @param userID        用户唯一标识
 @param model         模型
 @param finishedBlock 回调方法

 @return 队列
 */
+ (instancetype)animOperationWithUserID:(NSString *)userID model:(SJGiftModel *)model finish:(void(^)(BOOL result, NSInteger finishCount))finishedBlock;

@end

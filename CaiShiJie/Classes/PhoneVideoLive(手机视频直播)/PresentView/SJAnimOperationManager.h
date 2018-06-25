//
//  SJAnimOperationManager.h
//  CaiShiJie
//
//  Created by user on 18/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJGiftModel;
@interface SJAnimOperationManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) SJGiftModel *model;

/**
 动画操作

 @param userID        用户唯一标识
 @param model         模型
 @param finishedBlock 回调
 */
- (void)animWithUserID:(NSString *)userID model:(SJGiftModel *)model finishedBlock:(void(^)(BOOL result))finishedBlock;

/**
 取消上一次的动画操作

 @param userID 用户唯一标识
 */
- (void)cancelOperationWithLastUserID:(NSString *)userID;

@end

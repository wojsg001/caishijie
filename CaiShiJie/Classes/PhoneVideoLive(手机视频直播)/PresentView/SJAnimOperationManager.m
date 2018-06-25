//
//  SJAnimOperationManager.m
//  CaiShiJie
//
//  Created by user on 18/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnimOperationManager.h"
#import "SJAnimOperation.h"
#import "SJPresentFlower.h"
#import "SJGiftModel.h"

@interface SJAnimOperationManager ();
/// 队列1
@property (nonatomic, strong) NSOperationQueue *queueOne;
/// 队列2
@property (nonatomic, strong) NSOperationQueue *queueTwo;
/// 操作缓存池
@property (nonatomic, strong) NSCache *operationCache;
/// 维护用户礼物信息
@property (nonatomic, strong) NSCache *userGiftInfos;

@end

@implementation SJAnimOperationManager

+ (instancetype)sharedManager {
    static SJAnimOperationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SJAnimOperationManager alloc] init];
    });
    return manager;
}

/**
 动画操作
 
 @param userID        用户唯一标识
 @param model         模型
 @param finishedBlock 回调
 */
- (void)animWithUserID:(NSString *)userID model:(SJGiftModel *)model finishedBlock:(void(^)(BOOL result))finishedBlock {
    // 在有用户礼物信息时
    if ([self.userGiftInfos objectForKey:userID]) {
        // 如果有操作缓存，则直接累加，不需要重新创建op
        if ([self.operationCache objectForKey:userID] != nil) {
            SJAnimOperation *op = [self.operationCache objectForKey:userID];
            op.presentView.giftCount = model.giftCount;
            [op.presentView shakeNumberLabel];
            return;
        }
        // 没有操作缓存，创建op
        SJAnimOperation *op = [SJAnimOperation animOperationWithUserID:userID model:model finish:^(BOOL result, NSInteger finishCount) {
            // 回调
            if (finishedBlock) {
                finishedBlock(result);
            }
            // 将礼物信息数量存起来
            [self.userGiftInfos setObject:@(finishCount) forKey:userID];
            // 动画完成之后,要移除动画对应的操作
            [self.operationCache removeObjectForKey:userID];
            // 延时删除用户礼物信息
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.userGiftInfos removeObjectForKey:userID];
            });
        }];
        
        // 注意：下面两句代码是和无用户礼物信息时不同的，其余的逻辑一样
        op.presentView.animCount = [[self.userGiftInfos objectForKey:userID] integerValue];
        op.model.giftCount = op.presentView.animCount;
        
        op.listView = self.parentView;
        
        // 将操作添加到缓存池
        [self.operationCache setObject:op forKey:userID];
        // 根据队列中的操作数量控制显示位置
        if (self.queueOne.operationCount <= self.queueTwo.operationCount) {
            if (op.model.giftCount != 0) {
                op.presentView.frame = CGRectMake(-(self.parentView.frame.size.width - 190), 69, 190, 41);
                op.presentView.originFrame = op.presentView.frame;
                [self.queueOne addOperation:op];
            }
        } else {
            if (op.model.giftCount != 0) {
                op.presentView.frame = CGRectMake(-(self.parentView.frame.size.width - 190), 0, 190, 41);
                op.presentView.originFrame = op.presentView.frame;
                [self.queueTwo addOperation:op];
            }
        }
    } else { // 在没有用户礼物信息时
        // 如果有操作缓存，则直接累加，不需要重新创建op
        if ([self.operationCache objectForKey:userID] != nil) {
            SJAnimOperation *op = [self.operationCache objectForKey:userID];
            op.presentView.giftCount = model.giftCount;
            [op.presentView shakeNumberLabel];
            return;
        }
        
        SJAnimOperation *op = [SJAnimOperation animOperationWithUserID:userID model:model finish:^(BOOL result, NSInteger finishCount) {
            // 回调
            if (finishedBlock) {
                finishedBlock(result);
            }
            // 将礼物信息数量存起来
            [self.userGiftInfos setObject:@(finishCount) forKey:userID];
            // 动画完成之后,要移除动画对应的操作
            [self.operationCache removeObjectForKey:userID];
            // 延时删除用户礼物信息
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.userGiftInfos removeObjectForKey:userID];
            });
        }];
        op.listView = self.parentView;
        
        // 将操作添加到缓存池
        [self.operationCache setObject:op forKey:userID];
        // 根据队列中的操作数量控制显示位置
        if (self.queueOne.operationCount <= self.queueTwo.operationCount) {
            if (op.model.giftCount != 0) {
                op.presentView.frame = CGRectMake(-(self.parentView.frame.size.width - 190), 69, 190, 41);
                op.presentView.originFrame = op.presentView.frame;
                [self.queueOne addOperation:op];
            }
        } else {
            if (op.model.giftCount != 0) {
                op.presentView.frame = CGRectMake(-(self.parentView.frame.size.width - 190), 0, 190, 41);
                op.presentView.originFrame = op.presentView.frame;
                [self.queueTwo addOperation:op];
            }
        }
    }
}

/**
 取消上一次的动画操作
 
 @param userID 用户唯一标识
 */
- (void)cancelOperationWithLastUserID:(NSString *)userID {
    // 当上次为空时就不执行取消操作 (第一次进入执行时才会为空)
    if (userID == nil) return;
    
    [[self.operationCache objectForKey:userID] cancel];
}

- (NSOperationQueue *)queueOne {
    if (_queueOne == nil) {
        _queueOne = [[NSOperationQueue alloc] init];
        _queueOne.maxConcurrentOperationCount = 1;
    }
    return _queueOne;
}

- (NSOperationQueue *)queueTwo {
    if (_queueTwo == nil) {
        _queueTwo = [[NSOperationQueue alloc] init];
        _queueTwo.maxConcurrentOperationCount = 1;
    }
    return _queueTwo;
}

- (NSCache *)operationCache {
    if (_operationCache == nil) {
        _operationCache = [[NSCache alloc] init];
    }
    return _operationCache;
}

- (NSCache *)userGiftInfos {
    if (_userGiftInfos == nil) {
        _userGiftInfos = [[NSCache alloc] init];
    }
    return _userGiftInfos;
}

@end

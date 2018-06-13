//
//  SJAnimOperation.m
//  CaiShiJie
//
//  Created by user on 16/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnimOperation.h"
#import "SJPresentFlower.h"

@interface SJAnimOperation ()

@property (nonatomic, getter = isFinished)  BOOL finished;
@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, copy) void(^finishedBlock)(BOOL result,NSInteger finishCount);

@end

@implementation SJAnimOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

+ (instancetype)animOperationWithUserID:(NSString *)userID model:(SJGiftModel *)model finish:(void(^)(BOOL result, NSInteger finishCount))finishedBlock {
    SJAnimOperation *op = [[SJAnimOperation alloc] init];
    op.presentView = [[SJPresentFlower alloc] init];
    op.model = model;
    op.finishedBlock = finishedBlock;
    return op;
}

- (instancetype)init {
    if (self = [super init]) {
        _finished = NO;
        _executing = NO;
    }
    return self;
}

- (void)start {
    if ([self isCancelled]) {
        self.finished = YES;
        return;
    }
    self.executing = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _presentView.model = _model;
        _presentView.originFrame = _presentView.frame;
        [self.listView addSubview:_presentView];
        
        [self.presentView animateWithCompleteBlock:^(BOOL finished, NSInteger finishCount) {
            self.finished = finished;
            self.finishedBlock(finished, finishCount);
        }];
    }];
}

#pragma mark - 手动触发 KVO
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

@end

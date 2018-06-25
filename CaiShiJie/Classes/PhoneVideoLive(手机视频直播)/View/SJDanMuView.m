//
//  SJDanMuView.m
//  CaiShiJie
//
//  Created by user on 18/8/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJDanMuView.h"
#import "BarrageRenderer.h"
#import "BarrageWalkImageTextSprite.h"
#import "SJVideoInteractiveModel.h"
#import "MJExtension.h"

@interface SJDanMuView ()<BarrageRendererDelegate>

@property (nonatomic, strong) BarrageRenderer *renderer;
@property (nonatomic, strong) NSDate *startTime;

@end

@implementation SJDanMuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setupChildViews];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInteract:) name:KNotificationAddInteract object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLunxunInteract:) name:KNotificationAddLunXUnInteract object:nil];
}

#pragma mark - 接收添加互动的通知
- (void)addInteract:(NSNotification *)n {
    NSDictionary *dict = n.object;
    SJVideoInteractiveModel *model = [SJVideoInteractiveModel objectWithKeyValues:dict];
    [self sendDanMuContent:model.attributedString];
}

#pragma mark - 接收添加轮询互动的通知
- (void)addLunxunInteract:(NSNotification *)n{
    NSArray *tmpArray = n.object;
    NSArray *modelArray = [SJVideoInteractiveModel objectArrayWithKeyValuesArray:tmpArray];
    for (SJVideoInteractiveModel *model in modelArray) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendDanMuContent:model.attributedString];
        });
    }
}

- (void)setupChildViews {
    _renderer = [[BarrageRenderer alloc] init];
    _renderer.delegate = self;
    _renderer.redisplay = NO;
    [self addSubview:_renderer.view];
    [self sendSubviewToBack:_renderer.view];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 开始弹幕
    [self startDanMu];
}

/**
 *  开始弹幕
 */
- (void)startDanMu {
    _startTime = [NSDate date];
    [_renderer start];
}

- (void)sendDanMuContent:(NSMutableAttributedString *)attString {
    [_renderer receive:[self walkImageTextSpriteDescriptorAWithDirection:BarrageWalkDirectionR2L attString:attString]];
}

#pragma mark - 弹幕描述符生产方法
/**
 *  图文混排精灵弹幕
 *
 *  @param direction 弹幕方向
 *
 *  @return 精灵
 */
- (BarrageDescriptor *)walkImageTextSpriteDescriptorAWithDirection:(NSInteger)direction attString:(NSMutableAttributedString *)attString {
    BarrageDescriptor *descriptor = [[BarrageDescriptor alloc] init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkImageTextSprite class]);
    descriptor.params[@"attributedText"] = attString;
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX + 50);
    descriptor.params[@"direction"] = @(direction);
    return descriptor;
}

#pragma mark - BarrageRendererDelegate
- (NSTimeInterval)timeForBarrageRenderer:(BarrageRenderer *)renderer {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_startTime];
    return interval;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
    [_renderer stop];
}

@end

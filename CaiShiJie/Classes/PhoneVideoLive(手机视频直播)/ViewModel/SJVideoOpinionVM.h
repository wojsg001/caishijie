//
//  SJVideoOpinionVM.h
//  CaiShiJie
//
//  Created by user on 16/7/27.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJVideoOpinionModel, TYTextContainer;
@interface SJVideoOpinionVM : NSObject

@property (nonatomic, strong) TYTextContainer *textContainer;

@property(strong, nonatomic) NSArray *emotionArray;//表情数组
@property(strong, nonatomic) NSArray *fontArray;//字体数组
@property(strong, nonatomic) NSArray *urlArray;//网址数组
@property(strong, nonatomic) NSArray *stockArray;//股票数组

@property (nonatomic, assign) CGRect headIconFrame;
@property (nonatomic, assign) CGRect timeFrame;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGRect backgroundFrame;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) SJVideoOpinionModel *videoOpinionModel;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic,assign) BOOL isRefresh;
@property (nonatomic,copy) void(^updateImageSize)(SJVideoOpinionVM *opinionF);

@end

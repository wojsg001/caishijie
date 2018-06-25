//
//  SJRecommendLogFrame.h
//  CaiShiJie
//
//  Created by user on 18/2/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SJRecommendLog;
@interface SJRecommendLogFrame : NSObject

@property (nonatomic, assign) CGRect head_imgF;
@property (nonatomic, assign) CGRect nicknameF;
@property (nonatomic, assign) CGRect created_atF;
@property (nonatomic, assign) CGRect honorF;
@property (nonatomic, assign) CGRect titleF;
@property (nonatomic, assign) CGRect summaryF;
@property (nonatomic, assign) CGRect clicks_imgF;
@property (nonatomic, assign) CGRect clicksF;
@property (nonatomic, assign) CGRect bottomViewF;

@property (nonatomic, assign) CGFloat cellH;
@property (nonatomic, strong) SJRecommendLog *logModel;

@end

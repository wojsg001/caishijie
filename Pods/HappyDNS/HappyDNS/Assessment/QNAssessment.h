//
//  Assessment.h
//  HappyDNS
//
//  Created by bailong on 16/7/19.
//  Copyright © 2018年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNJudge : NSObject

@end

@interface QNAssessment : NSObject

- (void)submitErrorRecord;
- (void)submitSpeedRecord;

@end

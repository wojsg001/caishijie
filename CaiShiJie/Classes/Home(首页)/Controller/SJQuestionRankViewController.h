//
//  SJQuestionRankViewController.h
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@interface SJQuestionRankViewController : SJBaseViewController

@property (nonatomic, copy) void (^showNoWifiViewBlock)();

- (void)loadQuestionRankData;

@end

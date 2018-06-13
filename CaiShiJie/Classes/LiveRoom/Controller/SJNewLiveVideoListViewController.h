//
//  SJNewLiveVideoListViewController.h
//  CaiShiJie
//
//  Created by user on 16/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@interface SJNewLiveVideoListViewController : SJBaseViewController

@property (nonatomic, copy) void(^skipToVideoCourseBlock)();
@property (nonatomic, copy) NSString *target_id;
@property (nonatomic, copy) NSString *total_count;

@end

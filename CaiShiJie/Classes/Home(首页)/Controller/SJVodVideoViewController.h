//
//  SJVodVideoViewController.h
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJRecommendVideoModel;
@interface SJVodVideoViewController : UIViewController

@property (nonatomic, copy) NSString *course_id;
@property (nonatomic, strong) SJRecommendVideoModel *recommendVideoModel;
@property (nonatomic, copy) NSString *vod_id;

@end

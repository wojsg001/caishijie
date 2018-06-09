//
//  SJRecommendLiveCell.h
//  CaiShiJie
//
//  Created by user on 16/1/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJLiveRoomModel;
@interface SJRecommendLiveCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineWidth;

@property (nonatomic, strong) SJLiveRoomModel *hotOrFireModel;
// 判断是今日热门、观点最多、互动最多
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) SJLiveRoomModel *model;

@end

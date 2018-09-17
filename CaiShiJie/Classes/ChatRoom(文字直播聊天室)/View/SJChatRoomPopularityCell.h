//
//  SJChatRoomPopularityCell.h
//  CaiShiJie
//
//  Created by user on 18/1/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJChatRoomPopularityModel;
@interface SJChatRoomPopularityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineWidth;

@property (nonatomic, strong) SJChatRoomPopularityModel *hotOrFireModel;
// 判断是人气排行，我的关注
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) SJChatRoomPopularityModel *model;

@end

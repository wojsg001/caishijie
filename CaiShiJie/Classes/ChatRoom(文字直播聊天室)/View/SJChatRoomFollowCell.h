//
//  SJChatRoomFollowCell.h
//  CaiShiJie
//
//  Created by user on 18/1/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJChatRoomFollowModel;
@interface SJChatRoomFollowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineWidth;

@property (nonatomic, strong) SJChatRoomFollowModel *hotOrFireModel;
// 判断是人气排行，我的关注
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) SJChatRoomFollowModel *model;

@end

//
//  SJLiveVideoTeacherCell.h
//  CaiShiJie
//
//  Created by user on 16/9/1.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJNewLiveVideoTeacherModel;
@interface SJLiveVideoTeacherCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *guanzhuButton;
@property (nonatomic, strong) SJNewLiveVideoTeacherModel *model;

@end
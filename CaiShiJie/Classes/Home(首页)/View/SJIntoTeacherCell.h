//
//  SJIntoTeacherCell.h
//  CaiShiJie
//
//  Created by user on 18/5/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJCustom;
@interface SJIntoTeacherCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *addAttentionBtn;
@property (nonatomic, strong) SJCustom *model;

@end

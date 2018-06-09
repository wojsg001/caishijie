//
//  SJCustomCell.h
//  testDemo
//
//  Created by user on 15/12/23.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJCustom;
@interface SJCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *zhixunBtn;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;

@property (nonatomic, strong) SJCustom *recommendMaster;

@end

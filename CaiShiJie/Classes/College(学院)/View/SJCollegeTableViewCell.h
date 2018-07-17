//
//  SJCollegeTableViewCell.h
//  CaiShiJie
//
//  Created by zhongtou on 2018/7/16.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJCollegeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *collegeCellNameCN;
@property (weak, nonatomic) IBOutlet UIView *collegeCellLine;
@property (weak, nonatomic) IBOutlet UILabel *collegeCellNameEN;
@property (weak, nonatomic) IBOutlet UIImageView *collegeCellBg;
@end

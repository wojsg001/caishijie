//
//  SJVideoSectionOneCell.h
//  CaiShiJie
//
//  Created by user on 16/7/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoInfoListModel;
@interface SJVideoSectionOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (nonatomic, strong) SJVideoInfoListModel *model;

@end

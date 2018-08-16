//
//  SJVodVideoSectionOneCell.h
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVodVideoInfoListModel;
@interface SJVodVideoSectionOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) SJVodVideoInfoListModel *model;

@end

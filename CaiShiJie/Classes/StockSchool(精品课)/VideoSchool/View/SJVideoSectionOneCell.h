//
//  SJVideoSectionOneCell.h
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoInfoListModel;
@interface SJVideoSectionOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UILabel *orFreeVideo;
@property (nonatomic, strong) SJVideoInfoListModel *model;

@end

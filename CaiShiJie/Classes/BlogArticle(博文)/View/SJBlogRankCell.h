//
//  SJBlogRankCell.h
//  CaiShiJie
//
//  Created by user on 16/5/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJBlogRankModel;
@interface SJBlogRankCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (nonatomic, strong) SJBlogRankModel *model;

@end

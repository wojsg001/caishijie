//
//  SJCourseViewSectionCell.h
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJSchoolVideoModel;
@interface SJCourseViewSectionCell : UICollectionViewCell

@property (nonatomic, strong) SJSchoolVideoModel *model;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;



@end

//
//  SJsecondsectionCell.h
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJSchoolVideoModel;
@interface SJsecondsectionCell : UICollectionViewCell

@property (nonatomic, strong) SJSchoolVideoModel *model;
@property (nonatomic, copy) void (^clickedPayButtonBlock)();
@property (nonatomic, copy) void (^clickedFreeWatchButtonBlock)();

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *freeButton;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;



@end

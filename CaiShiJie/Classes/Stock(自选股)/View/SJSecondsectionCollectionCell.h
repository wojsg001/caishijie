//
//  SJSecondsectionCollectionCell.h
//  CaiShiJie
//
//  Created by user on 16/5/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJSecondsectionCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right;
@property (weak, nonatomic) IBOutlet UIView *bottomview;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *zhangfu;
@property (weak, nonatomic) IBOutlet UILabel *stockname;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *pricepercent;

@end

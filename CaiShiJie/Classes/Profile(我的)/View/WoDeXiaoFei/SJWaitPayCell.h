//
//  SJWaitPayCell.h
//  CaiShiJie
//
//  Created by user on 16/3/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJBillModel;
@interface SJWaitPayCell : UITableViewCell

@property (nonatomic, strong) SJBillModel *billModel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end

//
//  SJGivePresentCell.h
//  CaiShiJie
//
//  Created by user on 16/11/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiftModel;
@interface SJGivePresentCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) SJGiftModel *giftModel;

@end

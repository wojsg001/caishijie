//
//  SJFullVideoGiftCell.h
//  CaiShiJie
//
//  Created by user on 16/8/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiftModel;
@interface SJFullVideoGiftCell : UICollectionViewCell

@property (nonatomic, strong) SJGiftModel *model;
- (void)setSelectIconHidden:(BOOL)hidden;

@end

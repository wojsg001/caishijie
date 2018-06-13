//
//  SJPresentCell.h
//  CaiShiJie
//
//  Created by user on 16/1/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiftModel;
@interface SJPresentCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic, strong) SJGiftModel *giftModel;

@end

//
//  SJVideoGiftItem.h
//  CaiShiJie
//
//  Created by user on 18/7/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiftModel;
@interface SJVideoGiftItem : UIButton

@property (nonatomic, strong) SJGiftModel *model;
- (void)selectedItem:(BOOL)selected;

@end

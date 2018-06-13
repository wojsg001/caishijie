//
//  SJGiftPayView.h
//  CaiShiJie
//
//  Created by user on 16/11/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJGiftModel;
@interface SJGiftPayView : UIView

@property (nonatomic, strong) SJGiftModel *giftModel;
@property (nonatomic, copy) NSString *targetid;
/**
 用户余额
 */
@property (nonatomic, copy) NSString *goldCount;
+ (void)showGiftPayViewWithGiftModel:(SJGiftModel *)model targetid:(NSString *)targetid goldCount:(NSString *)goldCount;

@end

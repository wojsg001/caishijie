//
//  SJPayView.h
//  CaiShiJie
//
//  Created by user on 18/11/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SJPayStyle) {
    SJPayStyleWeiXin,
    SJPayStyleAliPay,
    SJPayStyleOther,
};

typedef void(^PayBlock)(SJPayStyle style);

@class SJGiftModel;
@interface SJPayView : UIView

@property (nonatomic, strong) SJGiftModel *giftModel;
@property (nonatomic, copy) NSString *targetid;
@property (nonatomic, copy) NSString *itemtype;

+ (void)showSJPayViewWithGiftModel:(SJGiftModel *)model targetid:(NSString *)targetid itemtype:(NSString *)itemtype;

@end

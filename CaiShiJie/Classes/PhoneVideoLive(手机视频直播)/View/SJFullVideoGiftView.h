//
//  SJFullVideoGiftView.h
//  CaiShiJie
//
//  Created by user on 16/8/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJFullVideoGiftView : UIView

@property (nonatomic, copy) NSString *targetid;
@property (nonatomic, copy) void(^clickBuyGoldButtonBlock)();
@property (nonatomic, copy) void(^needSkipBlock)();

@end

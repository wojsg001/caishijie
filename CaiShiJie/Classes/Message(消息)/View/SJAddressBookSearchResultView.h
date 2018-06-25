//
//  SJAddressBookSearchResultView.h
//  CaiShiJie
//
//  Created by user on 18/10/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMineFansModel;
@interface SJAddressBookSearchResultView : UIView

@property (nonatomic, copy) void(^cancelKeyboardBlock)();
@property (nonatomic, copy) void(^didSelectRowBlock)(SJMineFansModel *model);
@property (nonatomic, strong) NSArray *dataArray;

@end

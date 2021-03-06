//
//  SJMoreToolViewController.h
//  CaiShiJie
//
//  Created by user on 18/3/24.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@protocol SJMoreToolViewControllerDelegate <NSObject>

- (void)ClickWhichButton:(NSInteger)index;

@end

@interface SJMoreToolViewController : SJBaseViewController

@property (nonatomic, weak) id<SJMoreToolViewControllerDelegate>delegate;

@end

//
//  SJComposeToolBar.h
//  CaiShiJie
//
//  Created by user on 18/1/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJComposeToolBar;
@protocol SJComposeToolBarDelegate <NSObject>

@optional
- (void)composeToolBar:(SJComposeToolBar *)toolBar didClickBtn:(NSInteger)index;

@end

@interface SJComposeToolBar : UIView

@property (nonatomic, weak) id<SJComposeToolBarDelegate> delegate;

@end

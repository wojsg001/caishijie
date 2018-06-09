//
//  SJShareView.h
//  CaiShiJie
//
//  Created by user on 16/1/11.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJShareViewDelegate <NSObject>

- (void)shareToWhereWith:(NSInteger)index;

@end

@interface SJShareView : UIView

@property (nonatomic, weak) id<SJShareViewDelegate>delegate;
+ (void)showShareViewWithDelegate:(id)delegate;
+ (void)hideShareView;

@end

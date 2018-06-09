//
//  SJRankHeadView.h
//  CaiShiJie
//
//  Created by user on 16/4/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJRankHeadView;
@protocol SJRankHeadViewDelegate <NSObject>

- (void)rankHeadView:(SJRankHeadView *)rankHeadView clickButtonDown:(NSInteger)index;

@end

@interface SJRankHeadView : UIView

@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (nonatomic, weak) id<SJRankHeadViewDelegate>delegate;

@end

//
//  SJHomeLiveHeadVIew.h
//  CaiShiJie
//
//  Created by user on 18/5/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJHomeLiveHeadVIew;
@protocol SJHomeLiveHeadVIewDelegate <NSObject>

- (void)homeLiveHeadVIew:(SJHomeLiveHeadVIew *)homeLiveHeadVIew didSelectedButton:(NSInteger)index;

@end

@interface SJHomeLiveHeadVIew : UIView

@property (nonatomic, weak) id<SJHomeLiveHeadVIewDelegate>delegate;

@end

//
//  SJProfileHeaderView.h
//  CaiShiJie
//
//  Created by user on 16/4/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJProfileHeaderViewDelegate <NSObject>

- (void)headerViewButtonClicked:(UIButton *)button;

@end

@interface SJProfileHeaderView : UIView

@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, weak) id<SJProfileHeaderViewDelegate>delegate;

@end

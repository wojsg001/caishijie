//
//  SJIssueView.h
//  CaiShiJie
//
//  Created by user on 16/1/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJIssueViewDelegate <NSObject>

- (void)showLoginViewFromOpinionView;
- (void)selectImageWithType:(NSInteger)type;

@end

@interface SJIssueView : UIView

@property (nonatomic, weak) id<SJIssueViewDelegate>delegate;

@end

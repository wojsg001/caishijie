//
//  SJQuestionRankPopView.h
//  CaiShiJie
//
//  Created by user on 16/4/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJQuestionRankPopView;
@protocol SJQuestionRankPopViewDelegate <NSObject>

- (void)questionRankPopView:(SJQuestionRankPopView *)questionRankPopView clickButtonDown:(NSInteger)index;

@end

@interface SJQuestionRankPopView : UIView

@property (nonatomic, weak) id<SJQuestionRankPopViewDelegate>delegate;

@end

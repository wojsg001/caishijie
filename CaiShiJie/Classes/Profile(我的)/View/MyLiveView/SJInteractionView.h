//
//  SJInteractionView.h
//  CaiShiJie
//
//  Created by user on 16/1/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJInteractionViewDelegate <NSObject>

- (void)showLoginViewFromInteractionView;
- (void)interactionSelectImageWithType:(NSInteger)type andReplyid:(NSString *)replyid;

@end

@interface SJInteractionView : UIView

@property (nonatomic, weak) id<SJInteractionViewDelegate>delegate;

@end

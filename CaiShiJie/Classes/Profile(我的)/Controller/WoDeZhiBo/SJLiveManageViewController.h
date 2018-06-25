//
//  SJLiveManageViewController.h
//  CaiShiJie
//
//  Created by user on 18/2/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJLiveManageViewControllerDelegate <NSObject>

// 选择点击了更多页面中的按钮
- (void)ClickWhichButton:(NSInteger)index;

@end

@interface SJLiveManageViewController : SJBaseViewController

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *attentionLabel;

@property (nonatomic, strong) NSString *target_id;
@property (nonatomic, weak) id<SJLiveManageViewControllerDelegate>delegate;


@end

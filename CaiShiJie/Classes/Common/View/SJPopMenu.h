//
//  SJPopMenu.h
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2018年 user. All rights reserved.
// 新增弹框

#import <UIKit/UIKit.h>

@interface SJPopMenu : UIImageView

//显示弹出菜单
+ (instancetype)showInRect:(CGRect)rect;

//隐藏弹出菜单
+ (void)hide;

@property (nonatomic,weak) UIView *contentView;

@end

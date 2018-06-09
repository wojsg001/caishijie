//
//  SJTabBar.m
//  CaiShiJie
//
//  Created by user on 16/12/1.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTabBar.h"
#import "SJTabBarButton.h"
#import "SJTabBarBigButton.h"

@interface SJTabBar ()

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, weak) UIButton *selectedButton;

@end

@implementation SJTabBar

- (NSMutableArray *)buttons {
    if (_buttons == nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        topLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
        [self addSubview:topLine];
    }
    return self;
}

- (void)setItems:(NSArray *)items {
    _items = items;
    
    [_items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 2) {
            SJTabBarBigButton *button = [SJTabBarBigButton buttonWithType:UIButtonTypeCustom];
            button.item = (UITabBarItem *)obj;
            button.tag = idx;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
            [self.buttons addObject:button];
        } else {
            SJTabBarButton *button = [SJTabBarButton buttonWithType:UIButtonTypeCustom];
            button.item = (UITabBarItem *)obj;
            button.tag = idx;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
            if (button.tag == 0) {
                // 默认选中第一个
                [self buttonClick:button];
            }
            [self addSubview:button];
            [self.buttons addObject:button];
        }
    }];
}

/**
 selectedViewController改变时，按钮选中状态跟着改变

 @param index 需要改变的按钮
 */
- (void)setupSelectedWhichOneButton:(NSInteger)index {
    UIButton *button = [self.buttons objectAtIndex:index];
    _selectedButton.selected = NO;
    button.selected = YES;
    _selectedButton = button;
}

// 点击tabBarButton调用
- (void)buttonClick:(UIButton *)button {
    _selectedButton.selected = NO;
    button.selected = YES;
    _selectedButton = button;
    
    // 通知tabBarVc切换控制器
    if (_delegate && [_delegate respondsToSelector:@selector(tabBar:didClickButton:)]) {
        [_delegate tabBar:self didClickButton:button.tag];
    }
}

// 调整子控件的位置
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = w / self.items.count;
    CGFloat btnH = h;
    
    int i = 0;
    // 设置tabBarButton的frame
    for (UIView *tabBarButton in self.buttons) {
        btnX = i * btnW;
        if (i == 2) {
            tabBarButton.frame = CGRectMake((w - 56) * 0.5, btnH - 60, 56, 60);
        } else {
            tabBarButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
        }
        i++;
    }
}

@end

//
//  SJComposeToolBar.m
//  CaiShiJie
//
//  Created by user on 16/1/15.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJComposeToolBar.h"

@interface SJComposeToolBar ()

@property (nonatomic, strong) NSMutableArray *starBtnArr;

@end

@implementation SJComposeToolBar

- (NSMutableArray *)starBtnArr
{
    if (_starBtnArr == nil)
    {
        _starBtnArr = [NSMutableArray array];
    }
    return _starBtnArr;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // 添加所有子控件
        [self setUpAllChildView];
        self.backgroundColor = RGB(245, 245, 248);
    }
    
    return self;
}

#pragma mark - 添加所有子控件
- (void)setUpAllChildView
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"评分:";
    label.textColor = RGB(76, 76, 76);
    label.tag = 101;
    [self addSubview:label];
    
    for (int i = 0; i < 5; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"news_user_icon_evaluate2"] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        
        [self.starBtnArr addObject:btn];
        
        [self addSubview:btn];
    }
}

- (void)btnClick:(UIButton *)button
{
    
    // 点击工具条的时候
    if ([_delegate respondsToSelector:@selector(composeToolBar:didClickBtn:)]) {
        [_delegate composeToolBar:self didClickBtn:button.tag];
        
        for (int i = 0; i < self.starBtnArr.count; i++)
        {
            if (i <= button.tag)
            {
                UIButton *btn = self.starBtnArr[i];
                [btn setImage:[UIImage imageNamed:@"news_user_icon2"] forState:UIControlStateNormal];
            }
            else
            {
                UIButton *btn = self.starBtnArr[i];
                [btn setImage:nil forState:UIControlStateNormal];
            }
            
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UILabel *label = (UILabel *)[self viewWithTag:101];
    CGSize labelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    label.frame = (CGRect){{10, 12}, labelSize};
    
    CGFloat offX = CGRectGetMaxX(label.frame) + 5;
    CGFloat x;
    CGFloat y = 10;
    CGFloat w = 20;
    CGFloat h = 20;
    
    for (int i = 0; i < self.starBtnArr.count; i++)
    {
        UIButton *btn = self.starBtnArr[i];
        x = offX + i * (w + 4);
        btn.frame = CGRectMake(x, y, w, h);
    }
}


@end

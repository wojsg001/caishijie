//
//  SJBlogArticleView.m
//  CaiShiJie
//
//  Created by user on 18/4/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogArticleTypeView.h"

@interface SJBlogArticleTypeView ()

@property (nonatomic, weak) UIButton *lastSelectedBtn;

@end

@implementation SJBlogArticleTypeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = RGB(237, 237, 237);
    }
    return self;
}

- (void)setTypeArr:(NSArray *)typeArr
{
    _typeArr = typeArr;
    
    for (NSDictionary *tmpDic in _typeArr)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"article_btn_n"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"article_btn_h"] forState:UIControlStateSelected];
        [btn setTitle:tmpDic[@"name"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
        btn.tag = [tmpDic[@"type_id"] integerValue];
        btn.layer.borderWidth = 0.5f;
        btn.layer.borderColor = RGB(227, 227, 227).CGColor;
        btn.layer.cornerRadius = 4.0f;
        btn.layer.masksToBounds = YES;
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }
    
    UIButton *btn = self.subviews[0];
    btn.selected = YES;
    self.lastSelectedBtn = btn;
}

- (void)btnClick:(UIButton *)button
{
    if (button == self.lastSelectedBtn)
    {
        return;
    }
    
    button.selected = YES;
    self.lastSelectedBtn.selected = NO;
    self.lastSelectedBtn = button;
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickWhichOneButton:)])
    {
        [self.delegate didClickWhichOneButton:button.tag];
    }

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger cols = 1;
    CGFloat w = (self.width - 2 * 22 - 15) / cols;
    CGFloat h = 35;
    
    CGFloat x = 0;
    CGFloat y = 0;
    NSInteger col = 0;
    NSInteger row = 0;
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton *btn = self.subviews[i];
        col = i % cols; // 列
        row = i / cols; // 行
        x = 22 + col * (w + 15);
        y = 20 + row * (35 + 10);
        btn.frame = CGRectMake(x, y, w, h);
    }
}

@end

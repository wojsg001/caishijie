//
//  SJBookDetailFootView.m
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBookDetailFootView.h"

@interface SJBookDetailFootView ()

@end

@implementation SJBookDetailFootView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        
        _innerView.frame = frame;
        [self addSubview:_innerView];
    }
    return self;
}
// 首页
- (IBAction)firstPageBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(firstPageBtnClickDown)])
    {
        [self.delegate firstPageBtnClickDown];
    }
}
// 上一页
- (IBAction)beforePageBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beforePageBtnClickDown)])
    {
        [self.delegate beforePageBtnClickDown];
    }
}
// 下一页
- (IBAction)nextPageBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nextPageBtnClickDown)])
    {
        [self.delegate nextPageBtnClickDown];
    }
}
// 尾页
- (IBAction)lastPageBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(lastPageBtnClickDown)])
    {
        [self.delegate lastPageBtnClickDown];
    }
}

@end

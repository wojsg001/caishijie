//
//  SJHomeLiveHeadVIew.m
//  CaiShiJie
//
//  Created by user on 16/5/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJHomeLiveHeadVIew.h"

@interface SJHomeLiveHeadVIew ()

@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation SJHomeLiveHeadVIew

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        [self addSubview:_innerView];
        _bgView.layer.borderColor = RGB(227, 227, 227).CGColor;
        _bgView.layer.borderWidth = 0.5f;
        
    }
    return self;
}

- (IBAction)clickButton:(id)sender
{
    UIButton *btn = sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeLiveHeadVIew:didSelectedButton:)])
    {
        [self.delegate homeLiveHeadVIew:self didSelectedButton:btn.tag];
    }
}

@end

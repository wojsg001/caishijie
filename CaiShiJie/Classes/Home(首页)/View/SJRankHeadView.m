//
//  SJRankHeadView.m
//  CaiShiJie
//
//  Created by user on 16/4/21.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJRankHeadView.h"

@interface SJRankHeadView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeight;
@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UIView *giftView;
@property (weak, nonatomic) IBOutlet UIView *peopleView;
@property (weak, nonatomic) IBOutlet UIView *logView;

@end

@implementation SJRankHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        [self addSubview:_innerView];
        
        self.bottomLineHeight.constant = 0.5f;
    }
    return self;
}

- (IBAction)clickButtonDown:(id)sender
{
    UIButton *btn = sender;
    
    switch (btn.tag) {
        case 101:
            self.questionView.backgroundColor = RGB(244, 244, 244);
            self.giftView.backgroundColor = [UIColor whiteColor];
            self.peopleView.backgroundColor = [UIColor whiteColor];
            self.logView.backgroundColor = [UIColor whiteColor];
            break;
        case 102:
            self.questionView.backgroundColor = [UIColor whiteColor];
            self.giftView.backgroundColor = RGB(244, 244, 244);
            self.peopleView.backgroundColor = [UIColor whiteColor];
            self.logView.backgroundColor = [UIColor whiteColor];
            break;
        case 103:
            self.questionView.backgroundColor = [UIColor whiteColor];
            self.giftView.backgroundColor = [UIColor whiteColor];
            self.peopleView.backgroundColor = RGB(244, 244, 244);
            self.logView.backgroundColor = [UIColor whiteColor];
            break;
        case 104:
            self.questionView.backgroundColor = [UIColor whiteColor];
            self.giftView.backgroundColor = [UIColor whiteColor];
            self.peopleView.backgroundColor = [UIColor whiteColor];
            self.logView.backgroundColor = RGB(244, 244, 244);
            break;
            
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rankHeadView:clickButtonDown:)])
    {
        [self.delegate rankHeadView:self clickButtonDown:btn.tag];
    }
}

@end

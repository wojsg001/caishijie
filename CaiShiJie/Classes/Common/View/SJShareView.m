//
//  SJShareView.m
//  CaiShiJie
//
//  Created by user on 16/1/11.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJShareView.h"

#define KShareViewBackgroundViewTag 1111
#define KShareViewTag 2222

@interface SJShareView ()

@end

@implementation SJShareView

+ (void)showShareViewWithDelegate:(id)delegate {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH)];
    view.tag = KShareViewBackgroundViewTag;
    SJShareView *shareView = [[NSBundle mainBundle] loadNibNamed:@"SJShareView" owner:nil options:nil].lastObject;
    shareView.frame = CGRectMake(0, SJScreenH, SJScreenW, 200);
    shareView.delegate = delegate;
    shareView.tag = KShareViewTag;
    [view addSubview:shareView];
    [SJKeyWindow addSubview:view];
    
    [UIView animateWithDuration:0.3 animations:^{
        view.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.5];
        shareView.y = SJScreenH - 200;
    } completion:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:0.9];
}

+ (void)hideShareView {
    [[SJKeyWindow viewWithTag:KShareViewBackgroundViewTag] removeFromSuperview];
}

- (IBAction)cancelBtnPressed:(id)sender {
    SJShareView *shareView = [SJKeyWindow viewWithTag:KShareViewTag];
    [UIView animateWithDuration:0.3 animations:^{
        shareView.y = SJScreenH;
    } completion:^(BOOL finished) {
        [[SJKeyWindow viewWithTag:KShareViewBackgroundViewTag] removeFromSuperview];
    }];
}

- (IBAction)shareBtnPressed:(id)sender {
    UIButton *btn = sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareToWhereWith:)]) {
        [self.delegate shareToWhereWith:btn.tag];
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

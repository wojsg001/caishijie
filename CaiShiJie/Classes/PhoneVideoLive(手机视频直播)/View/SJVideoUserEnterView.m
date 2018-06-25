//
//  SJVideoUserEnterView.m
//  CaiShiJie
//
//  Created by user on 18/11/23.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVideoUserEnterView.h"
#import <BlocksKit/BlocksKit.h>

@interface SJVideoUserEnterView ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation SJVideoUserEnterView

+ (void)showAnimateToView:(UIView *)view message:(NSString *)message {
    if (view == nil) return;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJPhoneLiveUI" owner:nil options:nil];
    SJVideoUserEnterView *enterView = [nib bk_match:^BOOL(id obj) {
        return [obj isKindOfClass:[SJVideoUserEnterView class]];
    }];
    enterView.message = message;
    enterView.frame = CGRectMake(-view.width, 0, view.width, view.height);
    [view addSubview:enterView];
    [UIView animateWithDuration:0.3 animations:^{
        enterView.frame = view.bounds;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                enterView.alpha = 0;
            } completion:^(BOOL finished) {
                [enterView removeFromSuperview];
            }];
        });
    }];
}

- (void)setMessage:(NSString *)message {
    _message = message;
    
    _textLabel.attributedText = [self geAttributedStringWithString:message];
}

- (NSMutableAttributedString *)geAttributedStringWithString:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@进入", string]];
    NSRange range = [[attributedString string] rangeOfString:string];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#f7f006" withAlpha:1] range:range];
    return attributedString;
}

@end

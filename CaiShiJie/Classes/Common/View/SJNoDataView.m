//
//  SJNoDataView.m
//  CaiShiJie
//
//  Created by user on 16/10/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNoDataView.h"

@implementation SJNoDataView

+ (void)showNoDataViewToView:(UIView *)view {
    if (view == nil) {
        return;
    }
    SJNoDataView *noDataView = [[SJNoDataView alloc] initWithFrame:view.bounds];
    [view addSubview:noDataView];
}

+ (void)hideNoDataViewFromView:(UIView *)view {
    if (view == nil) {
        return;
    }
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"num_icon"];
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"暂无数据";
    label.textColor = [UIColor colorWithHexString:@"#888888" withAlpha:1];
    label.font = [UIFont systemFontOfSize:14];
    [self addSubview:label];
    
    WS(weakSelf);
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf);
        make.centerY.equalTo(weakSelf.mas_centerY).offset(-30);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf);
    }];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

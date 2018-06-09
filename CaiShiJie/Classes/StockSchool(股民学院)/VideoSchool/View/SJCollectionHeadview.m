//
//  SJCollectionHeadview.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJCollectionHeadview.h"

@implementation SJCollectionHeadview

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)MoreBtn:(UIButton *)sender {
    NSLog(@"%li",(long)sender.tag);
    if ([self.delegate respondsToSelector:@selector(btnclick:)]) {
        [self.delegate btnclick:sender];
    }
}

@end

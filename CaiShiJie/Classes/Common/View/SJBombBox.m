//
//  SJBombBox.m
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBombBox.h"

@implementation SJBombBox

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)ClickBox:(id)sender {
    UIButton *btn = sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(respondClickEvent:)]) {
        [self.delegate respondClickEvent:btn.tag];
    }
}

@end

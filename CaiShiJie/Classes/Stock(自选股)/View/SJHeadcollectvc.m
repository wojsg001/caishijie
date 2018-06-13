//
//  SJHeadcollectvc.m
//  CaiShiJie
//
//  Created by user on 16/5/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHeadcollectvc.h"

@implementation SJHeadcollectvc

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)Morebtnclick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(morebtnClick:)]) {
        
        [self.delegate morebtnClick:sender];
        
    }
}

@end

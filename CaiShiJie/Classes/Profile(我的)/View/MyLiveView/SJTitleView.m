//
//  SJTitleView.m
//  CaiShiJie
//
//  Created by user on 16/2/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJTitleView.h"

@implementation SJTitleView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.head_imgView.layer.cornerRadius = 15;
    self.head_imgView.layer.masksToBounds = YES;
    
    self.nameLabel.textColor = [UIColor whiteColor];
    self.stateLabel.textColor = [UIColor whiteColor];
}

@end

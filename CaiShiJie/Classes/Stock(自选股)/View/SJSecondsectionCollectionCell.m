//
//  SJSecondsectionCollectionCell.m
//  CaiShiJie
//
//  Created by user on 16/5/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJSecondsectionCollectionCell.h"

@interface SJSecondsectionCollectionCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;

@end

@implementation SJSecondsectionCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineViewHeight.constant = 0.5f;
}

@end

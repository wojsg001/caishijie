//
//  SJThreesectionCollectionCell.m
//  CaiShiJie
//
//  Created by user on 18/5/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJThreesectionCollectionCell.h"

@interface SJThreesectionCollectionCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;

@end

@implementation SJThreesectionCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineViewHeight.constant = 0.5f;
}

@end

//
//  SJProfileCell.m
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJProfileCell.h"

@interface SJProfileCell ()

@property (weak, nonatomic) IBOutlet UIView *badgeValue;

@end

@implementation SJProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.badgeValue.layer.cornerRadius = 5;
    self.badgeValue.layer.masksToBounds = YES;
}

- (void)setBadgeValueHidden:(BOOL)hidden {
    self.badgeValue.hidden = hidden;
}

@end

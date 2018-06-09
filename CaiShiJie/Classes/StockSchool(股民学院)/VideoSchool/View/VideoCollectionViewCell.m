//
//  VideoCollectionViewCell.m
//  shipin
//
//  Created by user on 16/4/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@interface VideoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *titleVIew;

@end

@implementation VideoCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleVIew.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
}

@end

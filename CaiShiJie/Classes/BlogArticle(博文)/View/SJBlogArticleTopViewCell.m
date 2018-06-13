//
//  SJBlogArticleTopViewCell.m
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogArticleTopViewCell.h"

@interface SJBlogArticleTopViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SJBlogArticleTopViewCell

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;
    
    _iconImage.image = [UIImage imageNamed:_dict[@"icon"]];
    _titleLabel.text = _dict[@"title"];
}

@end

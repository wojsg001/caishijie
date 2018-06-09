//
//  SJRecommendBookCell.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJRecommendBookCell.h"
#import "SJBookListModel.h"
#import "UIImageView+WebCache.h"

@interface SJRecommendBookCell ()
// 存放imageView
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;


@end

@implementation SJRecommendBookCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageView.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.imageView.layer.borderWidth = 0.5f;
    self.titleView.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.titleView.layer.borderWidth = 0.5f;
}

- (void)setBookListModel:(SJBookListModel *)bookListModel
{
    _bookListModel = bookListModel;
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_bookListModel.cover_img]] placeholderImage:[UIImage imageNamed:@"li_book"]];
    
    _titleLabel.text = _bookListModel.title;
    _authorLabel.text = _bookListModel.author;
}

@end

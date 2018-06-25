//
//  SJMySendBlogArticleCell.m
//  CaiShiJie
//
//  Created by user on 18/4/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMySendBlogArticleCell.h"
#import "SJMyBlogArticleModel.h"
#import "UIImageView+WebCache.h"

@interface SJMySendBlogArticleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *head_imgView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *honorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *clicksLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicLabel;

@end

@implementation SJMySendBlogArticleCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setBlogArticleModel:(SJMyBlogArticleModel *)blogArticleModel {
    _blogArticleModel = blogArticleModel;
    
    [_head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_blogArticleModel.head_img]] placeholderImage:[UIImage imageNamed:@"attention_list_photo"]];
    _nicknameLabel.text = _blogArticleModel.user_name;
    _timeLabel.text = _blogArticleModel.created_at;
    _honorLabel.text = _blogArticleModel.honor;
    _titleL.text = _blogArticleModel.title;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_blogArticleModel.summary];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    // 设置行间距
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:14]
                             range:NSMakeRange(0, attributedString.length)];
    _summaryLabel.attributedText = attributedString;

    _clicksLabel.text = _blogArticleModel.clicks;
    
    if ([_blogArticleModel.permissions isEqualToString:@"0"]) {
        _publicLabel.text = @"公开";
    } else {
        _publicLabel.text = @"私密";
    }
}

@end

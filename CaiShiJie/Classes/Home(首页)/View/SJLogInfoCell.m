//
//  SJLogInfoCell.m
//  CaiShiJie
//
//  Created by user on 16/1/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLogInfoCell.h"
#import "SJLogDetail.h"
#import "UIImageView+WebCache.h"

@interface SJLogInfoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *head_imgView;
@property (weak, nonatomic) IBOutlet UILabel *user_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *created_atLabel;
@property (weak, nonatomic) IBOutlet UILabel *honorLabel;

@end

@implementation SJLogInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setLogDetail:(SJLogDetail *)logDetail
{
    _logDetail = logDetail;
    
    [self.head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_logDetail.head_img]] placeholderImage:[UIImage imageNamed:@"attention_list_diary_photo"]];
    self.user_nameLabel.text = _logDetail.user_name;
    self.created_atLabel.text = _logDetail.created_at;
    self.honorLabel.text = _logDetail.honor;
}

@end

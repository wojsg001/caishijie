//
//  SJMyTeacherCell.m
//  CaiShiJie
//
//  Created by user on 16/1/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyTeacherCell.h"
#import "SJMyTeacher.h"
#import "UIImageView+WebCache.h"

@interface SJMyTeacherCell ()

@property (weak, nonatomic) IBOutlet UIImageView *head_imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *honorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@end

@implementation SJMyTeacherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.head_imgView.layer.cornerRadius = 5.0f;
    self.head_imgView.layer.masksToBounds = YES;
    self.lineHeight.constant = 0.5f;
}

- (void)setMyTeacher:(SJMyTeacher *)myTeacher
{
    _myTeacher = myTeacher;
    
    [self.head_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_myTeacher.head_img]] placeholderImage:[UIImage imageNamed:@"pho_mytg"]];
    self.nameLabel.text = _myTeacher.nickname;
    self.honorLabel.text = _myTeacher.honor;
    self.timeLabel.text = _myTeacher.created_at;
    
}

@end

//
//  SJsecondsectionCell.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJsecondsectionCell.h"
#import "SJSchoolVideoModel.h"

@interface SJsecondsectionCell ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UIImageView *imagevc;
@property (weak, nonatomic) IBOutlet UILabel *courselable;

@end

@implementation SJsecondsectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
}

- (void)setModel:(SJSchoolVideoModel *)model {
    if (_model != model) {
        _model = model;
    }
    
    _nickname.text = _model.nickname;
    [_imagevc sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.img]] placeholderImage:[UIImage imageNamed:@"live_img-1"]];
    _courselable.text = _model.course_name;
}

@end

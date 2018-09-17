//
//  SJCourseViewSectionCell.m
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCourseViewSectionCell.h"
#import "SJSchoolVideoModel.h"

@interface SJCourseViewSectionCell ()

@property (weak, nonatomic) IBOutlet UIView *miniTitleView;
@property (weak, nonatomic) IBOutlet UIImageView *imagevc;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *introductView;
@property (weak, nonatomic) IBOutlet UILabel *numOfPeople;
@end

@implementation SJCourseViewSectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.miniTitleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    
    self.imagevc.layer.cornerRadius = 10.0f;
    
    self.imagevc.clipsToBounds = YES;
}

- (void)setModel:(SJSchoolVideoModel *)model {
    if (_model != model) {
        _model = model;
    }
    
    [_imagevc sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.img]] placeholderImage:[UIImage imageNamed:@"live_img-1"]];
    _titleView.text = _model.course_name;
    _titleView.lineBreakMode = NSLineBreakByTruncatingTail;
    _introductView.text = model.introduce;
       
}


@end

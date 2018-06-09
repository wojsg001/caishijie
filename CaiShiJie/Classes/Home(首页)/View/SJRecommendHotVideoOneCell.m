//
//  SJRecommendHotVideoOneCell.m
//  CaiShiJie
//
//  Created by user on 16/5/13.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJRecommendHotVideoOneCell.h"
#import "SJRecommendVideoModel.h"

@interface SJRecommendHotVideoOneCell ()

@property (weak, nonatomic) IBOutlet UIView *titleViewOne;
@property (weak, nonatomic) IBOutlet UIView *titleViewTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewOne;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabelOne;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTwo;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabelTwo;

@end

@implementation SJRecommendHotVideoOneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleViewOne.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    self.titleViewTwo.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
}

- (void)setArray:(NSArray *)array {
    _array = array;
    
    SJRecommendVideoModel *modelOne = _array[0];
    [_imgViewOne sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,modelOne.img]] placeholderImage:[UIImage imageNamed:@"live_img-1"]];
    _titleLabelOne.text = modelOne.title;
    _nickNameLabelOne.text = modelOne.nickname;
    
    SJRecommendVideoModel *modelTwo = _array[1];
    [_imgViewTwo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,modelTwo.img]] placeholderImage:[UIImage imageNamed:@"live_img-1"]];
    _titleLabelTwo.text = modelTwo.title;
    _nickNameLabelTwo.text = modelTwo.nickname;
    
}

- (IBAction)clickBtnDown:(id)sender {
    UIButton *btn = sender;
    
    if (self.recommendHotVideoBlock) {
        self.recommendHotVideoBlock(btn.tag);
    }
}

@end

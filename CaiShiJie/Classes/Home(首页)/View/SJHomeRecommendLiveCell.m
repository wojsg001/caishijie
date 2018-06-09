//
//  SJHomeRecommendLiveCell.m
//  CaiShiJie
//
//  Created by user on 16/12/5.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJHomeRecommendLiveCell.h"
#import "SJLiveRoomModel.h"

@interface SJHomeRecommendLiveCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *total_countLabel;

@end

@implementation SJHomeRecommendLiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 45 / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setModel:(SJLiveRoomModel *)model {
    _model = model;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"attention_recommand_photo"]];
    self.nicknameLabel.text = _model.nickname;
    self.titleL.text = _model.title;
    self.total_countLabel.attributedText = [self changeStringColor:_model.total_count withOriginalString:[NSString stringWithFormat:@"%@人参与", _model.total_count]];
}

- (NSMutableAttributedString *)changeStringColor:(NSString *)changeStr withOriginalString:(NSString *)originalStr {
    NSMutableAttributedString *hintStr = [[NSMutableAttributedString alloc] initWithString:originalStr];
    NSRange range = [[hintStr string] rangeOfString:changeStr];
    [hintStr addAttribute:NSForegroundColorAttributeName value:RGB(205, 45, 38) range:range];
    
    return hintStr;
}

@end

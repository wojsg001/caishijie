//
//  SJHomeRecommendLiveCell.m
//  CaiShiJie
//
//  Created by user on 18/12/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHomeRecommendLiveCell.h"
#import "SJLiveRoomModel.h"

@interface SJHomeRecommendLiveCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *liveBroadcastImageView;
@property (weak, nonatomic) IBOutlet UILabel *fieryTitleL;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;


@end

@implementation SJHomeRecommendLiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 45 / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setModel:(SJLiveRoomModel *)model {
    _model = model;
    
    [self.headImageView setImage:[UIImage imageNamed:@"recommand_livephoto"]];
     //sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"attention_recommand_photo"]];
    self.nicknameLabel.text = @"黑马王陈文";//_model.nickname;
    self.fieryTitleL.text = @"热度:500";
    self.fansLabel.text= @"粉丝：300";
}

- (NSMutableAttributedString *)changeStringColor:(NSString *)changeStr withOriginalString:(NSString *)originalStr {
    NSMutableAttributedString *hintStr = [[NSMutableAttributedString alloc] initWithString:originalStr];
    NSRange range = [[hintStr string] rangeOfString:changeStr];
    [hintStr addAttribute:NSForegroundColorAttributeName value:RGB(205, 45, 38) range:range];
    
    return hintStr;
}

@end

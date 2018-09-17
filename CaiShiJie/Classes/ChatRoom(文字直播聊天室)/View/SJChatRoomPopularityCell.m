//
//  SJChatRoomPopularityCell.m
//  CaiShiJie
//
//  Created by user on 18/1/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJChatRoomPopularityCell.h"
#import "SJChatRoomPopularityModel.h"

@interface SJChatRoomPopularityCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *total_countLabel;

@end

@implementation SJChatRoomPopularityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 45 / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setHotOrFireModel:(SJChatRoomPopularityModel *)hotOrFireModel {
    _hotOrFireModel = hotOrFireModel;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_hotOrFireModel.head_img]] placeholderImage:[UIImage imageNamed:@"attention_recommand_photo"]];
    self.nicknameLabel.text = _hotOrFireModel.nickname;
    self.total_countLabel.attributedText = [self changeStringColor:_hotOrFireModel.total_count withOriginalString:[NSString stringWithFormat:@"人气值 %@", _hotOrFireModel.total_count]];
}

- (void)setModel:(SJChatRoomPopularityModel *)model {
    _model = model;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_model.head_img]] placeholderImage:[UIImage imageNamed:@"attention_recommand_photo"]];
    self.nicknameLabel.text = _model.nickname;
    
    switch (self.index) {
        case 101:
            self.total_countLabel.attributedText = [self changeStringColor:_model.total_count withOriginalString:[NSString stringWithFormat:@"人气值 %@", _model.total_count]];
            break;
        case 102:
            self.total_countLabel.attributedText = [self changeStringColor:_model.opinion_count withOriginalString:[NSString stringWithFormat:@"%@条观点", _model.opinion_count]];
            break;
        case 103:
            self.total_countLabel.attributedText = [self changeStringColor:_model.comment_count withOriginalString:[NSString stringWithFormat:@"%@条互动", _model.comment_count]];
            break;
            
        default:
            break;
    }
}

- (NSMutableAttributedString *)changeStringColor:(NSString *)changeStr withOriginalString:(NSString *)originalStr {
    NSMutableAttributedString *hintStr = [[NSMutableAttributedString alloc] initWithString:originalStr];
    NSRange range = [[hintStr string] rangeOfString:changeStr];
    [hintStr addAttribute:NSForegroundColorAttributeName value:RGB(205, 45, 38) range:range];

    return hintStr;
}

@end

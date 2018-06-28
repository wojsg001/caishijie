//
//  SJProfileHeaderView.m
//  CaiShiJie
//
//  Created by user on 18/4/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJProfileHeaderView.h"

@interface SJProfileHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;

@end

@implementation SJProfileHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
    self.head_img.layer.cornerRadius = self.head_img.frame.size.width / 2;
    self.head_img.layer.masksToBounds = YES;
    self.head_img.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *headImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgTap:)];
    [self.head_img addGestureRecognizer:headImgTap];
}

- (void)setDict:(NSDictionary *)dict {
    _dict = dict;
    
    // SJLog(@"%@", _dict);
    if (![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"散户哨兵"] && ![[SJUserDefaults valueForKey:kUserName] isEqualToString:@"hanxiao"]) {
        self.goldCoinLabel.attributedText = [self getMutableAttributedStringWithString:_dict[@"account"]];
        [self.goldCoinLabel sizeToFit];
    } else {
        self.goldCoinLabel.attributedText = [self getMutableAttributedStringWithString:@"0"];
        [self.goldCoinLabel sizeToFit];
    }
    
    if ([_dict[@"level"] isEqualToString:@"10"]) {
        // 如果是老师身份
        [_secondButton setTitle:@"开启视频" forState:UIControlStateNormal];
        [_secondButton setImage:[UIImage imageNamed:@"mine_icon_r"] forState:UIControlStateNormal];
    } else {
        // 普通身份
        [_secondButton setTitle:@"我的老师" forState:UIControlStateNormal];
        [_secondButton setImage:[UIImage imageNamed:@"mine_icon_r2"] forState:UIControlStateNormal];
    }
    
    self.nickNameLabel.text = _dict[@"nickname"];
    [self.head_img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,_dict[@"head_img"]]] placeholderImage:[UIImage imageNamed:@"mine_photo"]];
    self.fansLabel.text = [NSString stringWithFormat:@"粉丝：%@",_dict[@"fans"]];
    self.attentionLabel.text = [NSString stringWithFormat:@"关注：%@",_dict[@"attention"]];
}

- (NSMutableAttributedString *)getMutableAttributedStringWithString:(NSString *)string {
    //NSString *str =[NSString stringWithFormat:@"余额：%@币", string];
    NSString *str =[NSString stringWithFormat:@"提醒：%@条", string];
    NSMutableAttributedString *hintStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range = [[hintStr string] rangeOfString:string];
    [hintStr addAttribute:NSForegroundColorAttributeName value:RGB(255, 193, 8) range:range];
    [hintStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:range];

    return hintStr;
}

- (IBAction)buttonPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(headerViewButtonClicked:)]) {
        [_delegate headerViewButtonClicked:(UIButton *)sender];
    }
}

- (IBAction)headImgTap:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(headerViewButtonClicked:)]) {
        [_delegate headImgTapClicked];
    }
}
@end

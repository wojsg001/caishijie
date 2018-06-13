//
//  SJAddLiveInfoView.m
//  CaiShiJie
//
//  Created by user on 16/12/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAddLiveInfoView.h"
#import "SJVideoTeacherInfoModel.h"
#import "UIButton+AFNetworking.h"

@interface SJAddLiveInfoView ()

@end

@implementation SJAddLiveInfoView

- (void)layoutSubviews {
    [super layoutSubviews];

    NSMutableAttributedString *attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:_addTitleTextField.placeholder];
    [attributedPlaceholder addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attributedPlaceholder.length)];
    _addTitleTextField.attributedPlaceholder = attributedPlaceholder;
    [_startButton setBackgroundColor:[UIColor colorWithHexString:@"#f76408" withAlpha:0.5]];
    _startButton.layer.cornerRadius = 43/2;
    _startButton.layer.masksToBounds = YES;
    _startButton.layer.borderColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1].CGColor;
    _startButton.layer.borderWidth = 1.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.addTitleTextField endEditing:YES];
}

- (void)setModel:(SJVideoTeacherInfoModel *)model {
    _model = model;
    
    [_addImgButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.user_live_img]] placeholderImage:[UIImage imageNamed:@"add_photo"]];
    _addTitleTextField.text = _model.user_live_title;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    [_addImgButton setImage:image forState:UIControlStateNormal];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

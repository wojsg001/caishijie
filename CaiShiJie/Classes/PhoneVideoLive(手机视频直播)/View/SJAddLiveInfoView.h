//
//  SJAddLiveInfoView.h
//  CaiShiJie
//
//  Created by user on 16/12/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoTeacherInfoModel;
@interface SJAddLiveInfoView : UIView

@property (weak, nonatomic) IBOutlet UIButton *addImgButton;
@property (weak, nonatomic) IBOutlet UITextField *addTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) SJVideoTeacherInfoModel *model;

@end

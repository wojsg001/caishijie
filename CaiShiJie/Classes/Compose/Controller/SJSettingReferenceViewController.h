//
//  SJCreateNewReferenceViewController.h
//  CaiShiJie
//
//  Created by user on 16/3/31.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@protocol SJSettingReferenceViewControllerDelegate <NSObject>

- (void)didClickAddImageButton;

@end

@interface SJSettingReferenceViewController : SJBaseViewController

@property (nonatomic, weak) id<SJSettingReferenceViewControllerDelegate>delegate;

@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (weak, nonatomic) IBOutlet UIView *settingBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@end

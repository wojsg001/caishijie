//
//  SJBlogArticleSettingViewController.h
//  CaiShiJie
//
//  Created by user on 16/4/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@protocol SJBlogArticleSettingViewControllerDelegate <NSObject>

- (void)didClickAddImageButton;

@end

@interface SJBlogArticleSettingViewController : SJBaseViewController

@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIView *settingBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *publicBtn;
@property (weak, nonatomic) IBOutlet UIButton *privateBtn;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UITextField *labelTextField;
@property (weak, nonatomic) IBOutlet UIView *settingContentView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@property (nonatomic, strong) NSArray *imageArr;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, copy) NSString *blogType;

@property (nonatomic, weak) id<SJBlogArticleSettingViewControllerDelegate>delegate;

- (void)removeBlogArticleTypeView;// 移除选择类型视图

@end

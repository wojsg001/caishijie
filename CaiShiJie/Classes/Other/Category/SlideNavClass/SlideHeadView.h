//
//  SlideHeadView.h
//  slideNavDemo
//
//  Created by 冯学杰 on 16/3/31.
//  Copyright © 2018年 冯学杰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectTitleBtnBlock)(NSInteger index);

@interface SlideHeadView : UIView<UIScrollViewDelegate>

/** 文字scrollView  */
@property (nonatomic, strong) UIScrollView *titleScrollView;
/** 控制器scrollView  */
@property (nonatomic, strong) UIScrollView *contentScrollView;
/** 标签文字  */
@property (nonatomic, copy) NSArray * titlesArr;
/** 标签按钮  */
@property (nonatomic, strong) NSMutableArray *buttons;
/** 选中的按钮  */
@property (nonatomic, strong) UIButton * selectedBtn;
/** 选中的按钮背景图  */
@property (nonatomic, strong) UIImageView * imageBackView;

@property (nonatomic, copy) SelectTitleBtnBlock selectTitleBtnBlock;


-(void)setSlideHeadView;
-(void)addChildViewController:(UIViewController *)childVC title:(NSString *)vcTitle;
- (void)selectedWhichOneButtonWithTag:(NSInteger)index;

@end

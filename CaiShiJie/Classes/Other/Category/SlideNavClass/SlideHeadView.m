//
//  SlideHeadView.m
//  slideNavDemo
//
//  Created by 冯学杰 on 16/3/31.
//  Copyright © 2016年 冯学杰. All rights reserved.
//

#import "SlideHeadView.h"
#import "UIView+Extension.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

#define Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RandomColor Color(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))/** 随机色  */

static CGFloat const titleH = 44;/** 文字高度  */
static CGFloat const MaxScale = 1.2;/** 选中文字放大  */
#define kButtonWidth ScreenW/5 + 1

@implementation SlideHeadView

- (NSMutableArray *)buttons
{
    if (!_buttons)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

-(id)init{
    
    if (self = [super init])
    {

    }
    return self;
}

-(void)setSlideHeadView{

    [self setTitleScrollView];        /** 添加文字标签  */
    
    [self setContentScrollView];      /** 添加scrollView  */
    
    [self setupTitle];                /** 设置标签按钮 文字 背景图  */
    
    
    self.contentScrollView.contentSize = CGSizeMake(self.titlesArr.count * ScreenW, 0);
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsHorizontalScrollIndicator  = NO;
    self.contentScrollView.delegate = self;
    self.contentScrollView.bounces = NO;
}
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

#pragma mark - PRIVATE

-(void)addChildViewController:(UIViewController *)childVC title:(NSString *)vcTitle{
    UIViewController *superVC = [self findViewController:self];
    childVC.title = vcTitle;
    [superVC addChildViewController:childVC];
    
}
-(void)setTitleScrollView{
    UIViewController *superVC = [self findViewController:self];
    CGRect rect  = CGRectMake(0, 0, ScreenW, titleH);
    self.titleScrollView = [[UIScrollView alloc] initWithFrame:rect];
    
    [superVC.view addSubview:self.titleScrollView];
}
-(void)setContentScrollView{
    UIViewController *superVC = [self findViewController:self];
    
    CGFloat y  = CGRectGetMaxY(self.titleScrollView.frame);
    CGRect rect  = CGRectMake(0, y, ScreenW, ScreenH - titleH - 64 - 49);
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:rect];
    [superVC.view addSubview:self.contentScrollView];
}

-(void)setupTitle{
    UIViewController *superVC = [self findViewController:self];
    
    // 添加底部线条
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, titleH - 0.5, ScreenW + 5, 0.5)];
    bottomLine.backgroundColor = RGB(227, 227, 227);
    [self.titleScrollView addSubview:bottomLine];
    
    NSUInteger count = superVC.childViewControllers.count;
    CGFloat x = 0;
    CGFloat w = kButtonWidth;
    CGFloat h = titleH;
    self.imageBackView  = [[UIImageView alloc] initWithFrame:CGRectMake(5, titleH - 2, kButtonWidth - 10, 2)];
    self.imageBackView.image = [UIImage imageNamed:@"slider_icon"];
    self.imageBackView.backgroundColor = [UIColor whiteColor];
    self.imageBackView.userInteractionEnabled = YES;
    [self.titleScrollView addSubview:self.imageBackView];
    
    for (int i = 0; i < count; i++)
    {
        UIViewController *vc = superVC.childViewControllers[i];
        
        x = i * w;
        CGRect rect = CGRectMake(x, 0, w, h);
        UIButton *btn = [[UIButton alloc] initWithFrame:rect];
        
        btn.tag = i;
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchDown];
        
        [self.buttons addObject:btn];
        [self.titleScrollView addSubview:btn];
        
        
        if (i == 0)
        {
            [self click:btn];
        }
        
    }
    
    self.titleScrollView.contentSize = CGSizeMake(count * w, 0);
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    
}

-(void)click:(UIButton *)sender{
    
    [self selectTitleBtn:sender];
    NSInteger i = sender.tag;
    CGFloat x  = i *ScreenW;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    
    [self setUpOneChildController:i];
    if (self.selectTitleBtnBlock) {
        self.selectTitleBtnBlock(i);
    }
}

-(void)selectTitleBtn:(UIButton *)btn{
    
    [self.selectedBtn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
    self.selectedBtn.transform = CGAffineTransformIdentity;
    
    
    [btn setTitleColor:RGB(247, 100, 8) forState:UIControlStateNormal];
    btn.transform = CGAffineTransformMakeScale(MaxScale, MaxScale);
    self.selectedBtn = btn;
    
    [self setupTitleCenter:btn];
    
}

-(void)setupTitleCenter:(UIButton *)sender
{
    
    CGFloat offset = sender.center.x - ScreenW * 0.5;
    if (offset < 0) {
        offset = 0;
    }
    
    CGFloat maxOffset  = self.titleScrollView.contentSize.width - ScreenW;
    if (offset > maxOffset && maxOffset>0) {
        offset = maxOffset;
    }

    NSLog(@"%lf,%lf,%li",offset,maxOffset,(long)sender.tag);
    [self.titleScrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    
}

-(void)setUpOneChildController:(NSInteger)index{
    UIViewController *superVC = [self findViewController:self];
    
    CGFloat x  = index * ScreenW;
    UIViewController *vc  =  superVC.childViewControllers[index];
    if (vc.view.superview) {
        return;
    }
    vc.view.frame = CGRectMake(x, 0, ScreenW, self.contentScrollView.height);
    [self.contentScrollView addSubview:vc.view];
    
}


#pragma mark - UIScrollView  delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i  = self.contentScrollView.contentOffset.x / ScreenW;
    [self selectTitleBtn:self.buttons[i]];
    [self setUpOneChildController:i];
    if (self.selectTitleBtnBlock) {
        self.selectTitleBtnBlock(i);
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX  = scrollView.contentOffset.x;
    NSInteger leftIndex  = offsetX / ScreenW;
    NSInteger rightIdex  = leftIndex + 1;
    
    UIButton *leftButton = self.buttons[leftIndex];
    UIButton *rightButton  = nil;
    if (rightIdex < self.buttons.count) {
        rightButton  = self.buttons[rightIdex];
    }
    CGFloat scaleR  = offsetX / ScreenW - leftIndex;
    CGFloat scaleL  = 1 - scaleR;
    CGFloat transScale = MaxScale - 1;
    
    self.imageBackView.transform  = CGAffineTransformMakeTranslation((offsetX*(self.titleScrollView.contentSize.width / self.contentScrollView.contentSize.width)), 0);
    
    leftButton.transform = CGAffineTransformMakeScale(scaleL * transScale + 1, scaleL * transScale + 1);
    rightButton.transform = CGAffineTransformMakeScale(scaleR * transScale + 1, scaleR * transScale + 1);
    
    UIColor *rightColor = [UIColor colorWithRed:(68+179*scaleR)/255.0 green:(68+32*scaleR)/255.0 blue:(68-60*scaleR)/255.0 alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:(68+179*scaleL)/255.0 green:(68+32*scaleL)/255.0 blue:(68-60*scaleL)/255.0 alpha:1];
    
    [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
    [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
}

- (void)selectedWhichOneButtonWithTag:(NSInteger)index
{
    UIButton *btn = [self.titleScrollView viewWithTag:index];
    
    [self click:btn];
}

@end

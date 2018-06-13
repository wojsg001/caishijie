//
//  SJLiveManageViewController.m
//  CaiShiJie
//
//  Created by user on 16/2/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveManageViewController.h"
#import "SJOpinionViewController.h"
#import "SJInteractViewController.h"
#import "SJLiveGiftViewController.h"
#import "SJMoreToolViewController.h"
#import "SJUserInfo.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJGiftModel.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface SJLiveManageViewController ()<UIScrollViewDelegate,UIAlertViewDelegate,SJMoreToolViewControllerDelegate>
{
    BOOL isHideVideoToolBar;
}

// 存放菜单button
@property (nonatomic, strong) NSMutableArray           *menuBtnArr;
// 菜单下滑线
@property (nonatomic, strong) UIView                   *lineView;
@property (nonatomic, strong) UIScrollView             *scrollView;
@property (nonatomic, weak  ) UIButton                 *lastSelected;
@property (nonatomic, strong) UIView                   *titleView;
@property (nonatomic, strong) UIView                   *backgroundView;
@property (nonatomic, strong) UIImageView              *shadowView;
@property (nonatomic, strong) SJMoreToolViewController *moreToolVC;
@property (nonatomic, strong) SJInteractViewController *interactVC;
@property (nonatomic, strong) SJOpinionViewController  *opinionVC;
@property (nonatomic, strong) SJLiveGiftViewController *liveGiftVC;

@end

@implementation SJLiveManageViewController

- (UIView *)titleView
{
    if (_titleView == nil) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = RGB(244, 245, 248);
        _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleView;
}

- (SJMoreToolViewController *)moreToolVC
{
    if (_moreToolVC == nil) {
        _moreToolVC = [[SJMoreToolViewController alloc] init];
        _moreToolVC.delegate = self;
        [self addChildViewController:_moreToolVC];
    }
    return _moreToolVC;
}

- (SJInteractViewController *)interactVC
{
    if (_interactVC == nil) {
        _interactVC = [[SJInteractViewController alloc] init];
        _interactVC.target_id = self.target_id;
        [self addChildViewController:_interactVC];
    }
    return _interactVC;
}

- (SJOpinionViewController *)opinionVC
{
    if (_opinionVC == nil) {
        _opinionVC = [[SJOpinionViewController alloc] init];
        _opinionVC.target_id = self.target_id;
        [self addChildViewController:_opinionVC];
    }
    return _opinionVC;
}

- (SJLiveGiftViewController *)liveGiftVC {
    if (_liveGiftVC == nil) {
        _liveGiftVC = [[SJLiveGiftViewController alloc] init];
        _liveGiftVC.targetid = self.target_id;
        [self addChildViewController:_liveGiftVC];
    }
    return _liveGiftVC;
}

- (NSMutableArray *)menuBtnArr
{
    if (_menuBtnArr == nil) {
        _menuBtnArr = [NSMutableArray array];
    }
    return _menuBtnArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    isHideVideoToolBar = NO;
    
    // 设置直播标题
    [self setUpLive];
    // 设置菜单栏
    [self setUpMenuBar];
    // 设置显示View
    [self setUpView];
}

#pragma mark - 设置直播主题
- (void)setUpLive
{
    [self.view addSubview:self.titleView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    [self.titleView addSubview:_titleLabel];
    
    //设置约束
    WS(weakSelf);
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.titleView.mas_left).offset(10);
        make.right.equalTo(weakSelf.titleView.mas_right).offset(-10);
        make.centerY.mas_equalTo(weakSelf.titleView);
    }];
}

#pragma mark - 设置菜单栏
- (void)setUpMenuBar
{
    // 添加菜单栏背景
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor whiteColor];
    
    [self setUpButtonWithTitle:@"观点" tag:101 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"互动" tag:102 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"送礼" tag:103 target:self action:@selector(btnClick:)];
    [self setUpButtonWithTitle:@"更多" tag:104 target:self action:@selector(btnClick:)];
    
    
    for (int i = 0; i < self.menuBtnArr.count; i++) {
        UIButton *btn = self.menuBtnArr[i];
        btn.frame = CGRectMake((SJScreenW / 5) * i, 0, SJScreenW / 5, 38);
        if (i == 0) {
            // 将第0个按钮设置为选中状态
            btn.selected = YES;
            self.lastSelected = btn;
        }
        
        [_backgroundView addSubview:btn];
    }
    // 添加下滑线
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 38, SJScreenW / 5, 2)];
    _lineView.backgroundColor = RGB(247, 100, 8);
    [_backgroundView addSubview:_lineView];
    
    // 添加关注
    UIView *attentionView = [[UIView alloc] initWithFrame:CGRectMake(SJScreenW - SJScreenW / 5, 0, SJScreenW / 5, 40)];
    attentionView.backgroundColor = RGB(247, 100, 8);
    
    UIButton *attentionBtn = [[UIButton alloc] init];
    [attentionBtn setImage:[UIImage imageNamed:@"live_attention_icon"] forState:UIControlStateNormal];
    [attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
    attentionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [attentionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [attentionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    [attentionBtn sizeToFit];
    CGFloat attentionBtnW = attentionBtn.frame.size.width + 3;
    attentionBtn.frame = CGRectMake((SJScreenW / 5 - attentionBtnW) / 2 , 5, attentionBtnW, attentionBtn.frame.size.height);
    [attentionView addSubview:attentionBtn];
    
    _attentionLabel = [[UILabel alloc] init];
    _attentionLabel.text = @"88888";
    _attentionLabel.font = [UIFont systemFontOfSize:13];
    _attentionLabel.textColor = [UIColor whiteColor];
    _attentionLabel.textAlignment = NSTextAlignmentCenter;
    [_attentionLabel sizeToFit];
    _attentionLabel.frame = CGRectMake((SJScreenW / 5 - _attentionLabel.frame.size.width) / 2, 21, _attentionLabel.frame.size.width , _attentionLabel.frame.size.height);
    [attentionView addSubview:_attentionLabel];
    
    [_backgroundView addSubview:attentionView];
    [self.view addSubview:_backgroundView];
    
    //设置约束
    __weak __typeof(&*self)weakSelf = self;
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.equalTo(weakSelf.titleView.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.view.mas_left).offset(0);
        make.right.equalTo(weakSelf.view.mas_right).offset(0);
    }];
    
    // 添加底部阴影
    _shadowView = [[UIImageView alloc] init];
    _shadowView.image = [UIImage imageNamed:@"live_title_border_radius"];
    [self.view addSubview:_shadowView];
    
    [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.backgroundView.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(4);
    }];
}

#pragma mark - 设置显示View
- (void)setUpView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    //设置约束
    __weak __typeof(&*self)weakSelf = self;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.shadowView.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.view.mas_left).offset(0);
        make.bottom.equalTo(weakSelf.view.mas_bottom).offset(0);
        make.right.equalTo(weakSelf.view.mas_right).offset(0);
    }];
    
    _scrollView.contentSize = CGSizeMake(SJScreenW * 4, _scrollView.frame.size.height);
    
    // 将页面添加到scroll中
    [_scrollView addSubview:self.opinionVC.view];
    [_scrollView addSubview:self.interactVC.view];
    [_scrollView addSubview:self.liveGiftVC.view];
    [_scrollView addSubview:self.moreToolVC.view];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *curView = (UIView *)obj;
        [curView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(_scrollView.height);
            make.width.mas_equalTo(SJScreenW);
            make.left.mas_equalTo(SJScreenW * idx);
        }];
    }];
}

#pragma mark - 点击菜单事件
- (void)btnClick:(UIButton *)button
{
    [self setUpAnimateWith:button];
    [self.scrollView setContentOffset:CGPointMake(SJScreenW * (button.tag - 101), 0) animated:NO];
    
    if ([button isEqual:self.lastSelected]) {
        return;
    } else {
        button.selected = YES;
        self.lastSelected.selected = NO;
        self.lastSelected = button;
    }
    
    // 发送通知取消第一响应
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationResignFirstResponder object:nil];
}

#pragma mark - 设置动画效果
- (void)setUpAnimateWith:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.lineView.frame;
        rect.origin.x = button.frame.origin.x;
        self.lineView.frame = rect;
    } completion:^(BOOL finished) {
        // 获取到当前的View
        CALayer *viewLayer = self.lineView.layer;
        // 获取当前View的位置
        CGPoint position = viewLayer.position;
        // 移动的两个终点位置
        CGPoint x = CGPointMake(position.x + 5, position.y);
        CGPoint y = CGPointMake(position.x - 5, position.y);
        // 设置动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        // 设置运动形式
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        // 设置开始位置
        [animation setFromValue:[NSValue valueWithCGPoint:x]];
        // 设置结束位置
        [animation setToValue:[NSValue valueWithCGPoint:y]];
        // 设置自动反转
        [animation setAutoreverses:YES];
        // 设置时间
        [animation setDuration:0.03];
        // 设置次数
        [animation setRepeatCount:3];
        // 添加上动画
        [viewLayer addAnimation:animation forKey:nil];
    }];
}
// 设置菜单栏按钮
- (void)setUpButtonWithTitle:(NSString *)title tag:(NSInteger)tag target:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:RGB(247, 100, 8) forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    
    [self.menuBtnArr addObject:btn];
}

#pragma mark - UIScrollViewDelegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    [self moveToIndex:offset];
    
    if (offset <= 0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)moveToIndex:(float)x
{
    CGRect rect = self.lineView.frame;
    rect.origin.x = self.lineView.frame.size.width * x;
    self.lineView.frame = rect;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    
    int index = offset;
    for (int i = 0; i < self.menuBtnArr.count; i++)
    {
        UIButton *btn = self.menuBtnArr[i];
        // 判断当前应该选中哪个
        if (btn.tag == index + 101)
        {
            // 判断当前按钮是否是选中状态
            if (![btn isEqual:self.lastSelected])
            {
                btn.selected = YES;
                self.lastSelected.selected = NO;
                self.lastSelected = btn;
                break;
            }
        }
    }
    
    // 发送通知取消第一响应
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationResignFirstResponder object:nil];
}

#pragma mark - SJMoreToolViewControllerDelegate 代理方法
- (void)ClickWhichButton:(NSInteger)index
{
    // 选择历史/博文/内参直播时
    if (self.delegate && [self.delegate respondsToSelector:@selector(ClickWhichButton:)]) {
        [self.delegate ClickWhichButton:index];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s",__func__);
}

@end

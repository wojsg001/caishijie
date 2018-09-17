//
//  DLTabedSlideView.m
//  DLSlideController
//
//  Created by Dongle Su on 14-12-8.
//  Copyright (c) 2014年 dongle. All rights reserved.
//

#import "DLTabedSlideView.h"
#import "DLFixedTabbarView.h"
#import "DLSlideView.h"
#import "DLLRUCache.h"

#define kDefaultTabbarHeight 54
#define kDefaultTabbarBottomSpacing 0
#define kDefaultCacheCount 4

@implementation DLTabedbarItem
+ (DLTabedbarItem *)itemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    DLTabedbarItem *item = [[DLTabedbarItem alloc] init];
    item.title = title;
    item.image = image;
    item.selectedImage = selectedImage;
    
    return item;
}

@end

@interface DLTabedSlideView()<DLSlideViewDelegate, DLSlideViewDataSource>

@end


@implementation DLTabedSlideView{
    DLSlideView *slideView_;
    DLFixedTabbarView *tabbar_;
    DLLRUCache *ctrlCache_;
    DLTabedSlideViewType tabedSlideViewType_;
}

-(void)initWithDLTabedSlideViewType:(DLTabedSlideViewType)tabedSlideViewType{
    tabedSlideViewType_ = tabedSlideViewType;
    switch (tabedSlideViewType_) {
        case DLTabedSlideViewCommon:
             [self commonInit];
            break;
        case DLTabedSlideViewCourseVideo:
            [self commonInitCourseVideo];
        default:
            break;
    }
}


- (void)commonInit{
    self.tabbarHeight = kDefaultTabbarHeight;
    self.tabbarBottomSpacing = kDefaultTabbarBottomSpacing;
    
    tabbar_ = [[DLFixedTabbarView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.tabbarHeight)];
    tabbar_.delegate = self;
    [self addSubview:tabbar_];
    
    slideView_ = [[DLSlideView alloc] initWithFrame:CGRectMake(0, self.tabbarHeight+self.tabbarBottomSpacing, self.bounds.size.width, self.bounds.size.height-self.tabbarHeight-self.tabbarBottomSpacing - 64)];
    slideView_.delegate = self;
    slideView_.dataSource = self;
    [self addSubview:slideView_];
    
    ctrlCache_ = [[DLLRUCache alloc] initWithCount:4];
}

- (void)commonInitCourseVideo{
    self.tabbarHeight = kDefaultTabbarHeight;
    self.tabbarBottomSpacing = kDefaultTabbarBottomSpacing;
    
    tabbar_ = [[DLFixedTabbarView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.tabbarHeight)];
    tabbar_.delegate = self;
    [self addSubview:tabbar_];
    
    slideView_ = [[DLSlideView alloc] initWithFrame:CGRectMake(0, self.tabbarHeight+self.tabbarBottomSpacing + 170, self.bounds.size.width, self.bounds.size.height-self.tabbarHeight-self.tabbarBottomSpacing - 64)];
    slideView_.delegate = self;
    slideView_.dataSource = self;
    [self addSubview:slideView_];
    
    ctrlCache_ = [[DLLRUCache alloc] initWithCount:4];
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self layoutBarAndSlide];
}

- (void)layoutBarAndSlide{
    UIView *barView = (UIView *)tabbar_;
    barView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.tabbarHeight);

    
    switch (tabedSlideViewType_) {
        case DLTabedSlideViewCommon:
            slideView_.frame = CGRectMake(0, self.tabbarHeight+self.tabbarBottomSpacing, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-self.tabbarHeight-self.tabbarBottomSpacing - 64);
            break;
        case DLTabedSlideViewCourseVideo:
            slideView_.frame = CGRectMake(0, self.tabbarHeight+self.tabbarBottomSpacing + 170, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-self.tabbarHeight-self.tabbarBottomSpacing - 64);
        default:
            break;
    }
}
//- (void)setViewControllers:(NSArray *)viewControllers{
//    //assert(self.tabarView == nil || viewControllers.count == [self.tabarView tabbarCount]);
//
//    slideView_.viewControllers = viewControllers;
//}

- (void)setBaseViewController:(UIViewController *)baseViewController{
    slideView_.baseViewController = baseViewController;
}

- (void)buildTabbar{
    NSMutableArray *tabbarItems = [NSMutableArray array];
    for (DLTabedbarItem *item in self.tabbarItems) {
        DLFixedTabbarViewTabItem *barItem = [[DLFixedTabbarViewTabItem alloc] init];
        barItem.title = item.title;
        barItem.titleColor = self.tabItemNormalColor;
        barItem.selectedTitleColor = self.tabItemSelectedColor;
        barItem.image = item.image;
        barItem.selectedImage = item.selectedImage;
        
        [tabbarItems addObject:barItem];
    }
    
    tabbar_.tabbarItems = tabbarItems;
    tabbar_.trackColor = self.tabbarTrackColor;
    tabbar_.backgroundImage = self.tabbarBackgroundImage;

}
//- (void)setTabarView:(id<DLSlideTabbarProtocol>)tabarView{
//    assert([tabarView isKindOfClass:[UIView class]]);
//    assert(slideView_.viewControllers == nil || slideView_.viewControllers.count == [tabarView tabbarCount]);
//    
//    if (_tabarView != tabarView) {
//        _tabarView.delegate = nil;
//        _tabarView = tabarView;
//        
//        tabarView.delegate = self;
//        [self layoutBarAndSlide];
//
//    }
//}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    [slideView_ setSelectedIndex:selectedIndex];
    [tabbar_ setSelectedIndex:selectedIndex];
}

- (void)DLSlideTabbar:(id)sender selectAt:(NSInteger)index{
    [slideView_ setSelectedIndex:index];
}

- (NSInteger)numberOfControllersInDLSlideView:(DLSlideView *)sender{
    return [self.delegate numberOfTabsInDLTabedSlideView:self];
}

- (UIViewController *)DLSlideView:(DLSlideView *)sender controllerAt:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    if ([ctrlCache_ objectForKey:key]) {
        return [ctrlCache_ objectForKey:key];
    }
    else{
        UIViewController *ctrl = [self.delegate DLTabedSlideView:self controllerAt:index];
        [ctrlCache_ setObject:ctrl forKey:key];
        return ctrl;
    }
}

- (void)DLSlideView:(DLSlideView *)slide switchingFrom:(NSInteger)oldIndex to:(NSInteger)toIndex percent:(float)percent{
    [tabbar_ switchingFrom:oldIndex to:toIndex percent:percent];
}
- (void)DLSlideView:(DLSlideView *)slide didSwitchTo:(NSInteger)index{
    [tabbar_ setSelectedIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(DLTabedSlideView:didSelectedAt:)]) {
        [self.delegate DLTabedSlideView:self didSelectedAt:index];
    }
}
- (void)DLSlideView:(DLSlideView *)slide switchCanceled:(NSInteger)oldIndex{
    [tabbar_ setSelectedIndex:oldIndex];
}


@end

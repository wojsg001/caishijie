//
//  SJNewFeatureController.m
//  CaiShiJie
//
//  Created by user on 15/12/22.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJNewFeatureController.h"
#import "SJNewFeatureCell.h"

#define SJNewFeatureCount 4

@interface SJNewFeatureController ()

//@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation SJNewFeatureController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 取消滚动条
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    
    // 添加padgeController
    //[self setUpPadgeController];
}

//- (void)setUpPadgeController
//{
//    UIPageControl *page = [[UIPageControl alloc] init];
//    
//    page.center = CGPointMake(self.view.center.x, self.view.height * 0.95);
//    page.numberOfPages = SJNewFeatureCount;
//    page.currentPageIndicatorTintColor = RGB(247, 100, 8);
//    page.pageIndicatorTintColor = RGB(253, 208, 180);
//    _pageControl = page;
//    [self.view addSubview:page];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSInteger page = scrollView.contentOffset.x / scrollView.width + 0.5;
//    
//    _pageControl.currentPage = page;
//}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return SJNewFeatureCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 创建cell
    SJNewFeatureCell *cell = [SJNewFeatureCell cellWithCollectionView:collectionView indexPath:indexPath];
    
    NSString *imageName = [NSString stringWithFormat:@"guide%ld",(long)indexPath.row + 1];
    
    cell.imageName = imageName;
    
    [cell setIndexPath:indexPath pagecount:SJNewFeatureCount];
    
    return cell;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

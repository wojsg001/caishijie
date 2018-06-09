//
//  SJRecommendBlogArticleView.h
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJBlogArticleHeaderView, SJRecommendBlogArticleView;
@protocol SJRecommendBlogArticleViewDelegate <NSObject>

- (void)recommendBlogArticleView:(SJRecommendBlogArticleView *)recommendBlogArticleView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SJRecommendBlogArticleView : UICollectionViewCell<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) SJBlogArticleHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, weak) UICollectionViewFlowLayout *contentLayout;

@property (nonatomic, weak) NSArray *contentModelArray;

@property (nonatomic, weak) id<SJRecommendBlogArticleViewDelegate>delegate;

@end

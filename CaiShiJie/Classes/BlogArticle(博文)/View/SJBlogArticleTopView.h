//
//  SJBlogArticleTopView.h
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJBlogArticleTopView;
@protocol SJBlogArticleTopViewDelegate <NSObject>

- (void)blogArticleTopView:(SJBlogArticleTopView *)blogArticleTopView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SJBlogArticleTopView : UICollectionViewCell<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) NSArray *contentModelArray;

@property (nonatomic, weak) id<SJBlogArticleTopViewDelegate>delegate;

@end

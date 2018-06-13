//
//  SJBlogArticleWonderfulView.h
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJBlogArticleHeaderView;

typedef void(^BlogArticleBlock)(NSInteger row);

@interface SJBlogArticleWonderfulView : UICollectionViewCell<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) SJBlogArticleHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, weak) UICollectionViewFlowLayout *contentLayout;

@property (nonatomic, weak) NSArray *contentModelArray;
@property (nonatomic, copy) BlogArticleBlock blogArticleWonderfulViewBlock;

@end

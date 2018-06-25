//
//  SJBlogArticleWonderfulView.m
//  CaiShiJie
//
//  Created by user on 18/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogArticleWonderfulView.h"
#import "SJBlogArticleWonderfulViewCell.h"
#import "SJBlogArticleHeaderView.h"

@interface SJBlogArticleWonderfulView ()

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation SJBlogArticleWonderfulView

#pragma mark - 延迟实例化
- (SJBlogArticleHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[NSBundle mainBundle] loadNibNamed:@"SJBlogArticleHeaderView" owner:nil options:nil].lastObject;
    }
    return _headerView;
}

- (UICollectionView *)contentCollectionView{
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _contentCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentCollectionView.backgroundColor = [UIColor whiteColor];
        _contentCollectionView.scrollEnabled = NO;
        _contentCollectionView.showsVerticalScrollIndicator = NO;
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
        _contentLayout = layout;
        
        [self.contentCollectionView registerNib:[UINib nibWithNibName:@"SJBlogArticleWonderfulViewCell" bundle:nil] forCellWithReuseIdentifier:@"SJBlogArticleWonderfulViewCell"];
        self.contentLayout.minimumLineSpacing = 10;
        self.contentLayout.minimumInteritemSpacing = 0;
        self.contentLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.contentLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.contentCollectionView.scrollEnabled = YES;
    }
    return _contentCollectionView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    [self addSubview:self.headerView];
    [self addSubview:self.contentCollectionView];
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = RGB(245, 245, 248);
    [self addSubview:_bottomView];
    
    [self initSubViewLayouts];
}

- (void)initSubViewLayouts{
    WS(weakSelf);
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf);
        make.height.mas_equalTo(35);
    }];
    
    [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf).with.insets(UIEdgeInsetsMake(35, 0, 25, 0));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf);
        make.height.mas_equalTo(10);
    }];
}

- (void)setContentModelArray:(NSArray *)contentModelArray{
    _contentModelArray = contentModelArray;
    [self.contentCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contentModelArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = self.contentCollectionView.height;
    return CGSizeMake(height/ 200.0 * 450, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SJBlogArticleWonderfulViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJBlogArticleWonderfulViewCell" forIndexPath:indexPath];
    
    if (self.contentModelArray.count) {
        cell.model = self.contentModelArray[indexPath.row];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.blogArticleWonderfulViewBlock) {
        self.blogArticleWonderfulViewBlock(indexPath.row);
    }
}

@end

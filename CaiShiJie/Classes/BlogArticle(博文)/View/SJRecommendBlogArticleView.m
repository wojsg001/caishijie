//
//  SJRecommendBlogArticleView.m
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJRecommendBlogArticleView.h"
#import "SJRecommendBlogArticleCell.h"
#import "SJBlogArticleHeaderView.h"

@interface SJRecommendBlogArticleView ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation SJRecommendBlogArticleView

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
        
        [self.contentCollectionView registerNib:[UINib nibWithNibName:@"SJRecommendBlogArticleCell" bundle:nil]forCellWithReuseIdentifier:@"SJRecommendBlogArticleCell"];
        
        self.contentLayout.minimumLineSpacing = 0;
        self.contentLayout.itemSize = CGSizeMake(SJScreenW, 110);
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
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = RGB(227, 227, 227);
    [self addSubview:_lineView];

    [self initSubViewLayouts];
}

- (void)initSubViewLayouts{
    WS(weakSelf);
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf);
        make.height.mas_equalTo(35);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.headerView.mas_bottom).offset(0);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf).with.insets(UIEdgeInsetsMake(36, 0, 0, 0));
    }];
}

- (void)setContentModelArray:(NSArray *)contentModelArray{
    _contentModelArray = contentModelArray;
    [self.contentCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _contentModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SJRecommendBlogArticleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJRecommendBlogArticleCell" forIndexPath:indexPath];
    
    if (self.contentModelArray.count) {
        cell.model = self.contentModelArray[indexPath.row];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recommendBlogArticleView:didSelectItemAtIndexPath:)]) {
        [self.delegate recommendBlogArticleView:self didSelectItemAtIndexPath:indexPath];
    }
    
}

@end

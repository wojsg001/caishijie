//
//  SJBlogArticleTopView.m
//  CaiShiJie
//
//  Created by user on 18/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBlogArticleTopView.h"
#import "SJBlogArticleTopViewCell.h"

static NSString *blogArticleTopIdentifier = @"SJBlogArticleTopViewCell";
@interface SJBlogArticleTopView ()

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation SJBlogArticleTopView

- (UICollectionView *)contentCollectionView{
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        
        _contentCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentCollectionView.backgroundColor = [UIColor whiteColor];
        _contentCollectionView.scrollEnabled = NO;
        _contentCollectionView.showsVerticalScrollIndicator = NO;
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
        
        [_contentCollectionView registerNib:[UINib nibWithNibName:@"SJBlogArticleTopViewCell" bundle:nil] forCellWithReuseIdentifier:blogArticleTopIdentifier];
    }
    return _contentCollectionView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
    [self addSubview:self.contentCollectionView];
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = RGB(245, 245, 248);
    [self addSubview:_bottomView];
    
    [self initSubViewLayouts];
}

- (void)initSubViewLayouts{

    WS(weakSelf);
    [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf).with.insets(UIEdgeInsetsMake(0, 0, 8, 0));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentCollectionView.mas_bottom).offset(0);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(8);
    }];
}

- (void)setContentModelArray:(NSArray *)contentModelArray
{
    _contentModelArray = contentModelArray;
    [self.contentCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contentModelArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat width = (self.contentCollectionView.width - 40)/3;
    return CGSizeMake(width, 93);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SJBlogArticleTopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:blogArticleTopIdentifier forIndexPath:indexPath];
    cell.dict = self.contentModelArray[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(blogArticleTopView:didSelectItemAtIndexPath:)]) {
        [self.delegate blogArticleTopView:self didSelectItemAtIndexPath:indexPath];
    }
}

@end

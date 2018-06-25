//
//  SJPersonalSummaryTwoCell.m
//  CaiShiJie
//
//  Created by user on 18/10/8.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalSummaryTwoCell.h"
#import "SJPersonalSummaryTwoContentCell.h"

@interface SJPersonalSummaryTwoCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation SJPersonalSummaryTwoCell

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 7.5, 0, 7.5);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SJPersonalSummaryTwoContentCell class] forCellWithReuseIdentifier:@"SJPersonalSummaryTwoContentCell"];
    }
    return _collectionView;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"SJPersonalSummaryTwoCell";
    SJPersonalSummaryTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SJPersonalSummaryTwoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initChildView];
    }
    return self;
}

- (void)initChildView {
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _leftLine = [[UIView alloc] init];
    _leftLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.contentView addSubview:_leftLine];
    [_leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(0.5);
    }];
    
    _rightLine = [[UIView alloc] init];
    _rightLine.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.contentView addSubview:_rightLine];
    [_rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(0.5);
    }];
}

- (void)setContentArray:(NSArray *)contentArray {
    if (_contentArray != contentArray) {
        _contentArray = contentArray;
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.width;
    return CGSizeMake((width - 15)/3, 57);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJPersonalSummaryTwoContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJPersonalSummaryTwoContentCell" forIndexPath:indexPath];
    [cell sizeToFit];
    if (self.contentArray.count) {
        cell.title = self.contentArray[indexPath.row];
    }
    return cell;
}

@end

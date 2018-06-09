//
//  SJNewFeatureCell.m
//  CaiShiJie
//
//  Created by user on 15/12/22.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJNewFeatureCell.h"
#import "SJTabBarController.h"

static NSString *const reuseIdentifier = @"SJNewFeatureCell";
static UICollectionView *_collectionView = nil;

@interface SJNewFeatureCell()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *startBtn;

@end

@implementation SJNewFeatureCell

- (UIButton *)startBtn
{
    if (_startBtn == nil)
    {
        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [startBtn setImage:[UIImage imageNamed:@"guide4_btn_n"] forState:UIControlStateNormal];
        [startBtn setImage:[UIImage imageNamed:@"guide4_btn_h"] forState:UIControlStateHighlighted];
        [startBtn sizeToFit];
        startBtn.center = CGPointMake(self.width * 0.5, self.height * 0.9);
        [startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:startBtn];
        _startBtn = startBtn;
    }
    return _startBtn;
}

- (UIImageView *)imageView
{
    if (_imageView == nil)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView = imageView;
        [self addSubview:imageView];
    }
    return _imageView;
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    UIImage *image = [UIImage imageNamed:imageName];
    self.imageView.image = image;
}

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    // 注册UICollectionViewCell
    if (_collectionView == nil)
    {
        _collectionView = collectionView;
        [collectionView registerClass:[SJNewFeatureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
}

- (void)setIndexPath:(NSIndexPath *)indexPath pagecount:(NSInteger)pagecount
{
    
    if (indexPath.row == (pagecount -1)) {
        //添加进入按钮
        [self startBtn];
        self.startBtn.hidden = NO;
    } else {
        self.startBtn.hidden = YES;
    }
}

- (void)start {
    //进入首页
    SJTabBarController *tabBarVC = [[SJTabBarController alloc] init];
    SJKeyWindow.rootViewController = tabBarVC;
    
}

@end

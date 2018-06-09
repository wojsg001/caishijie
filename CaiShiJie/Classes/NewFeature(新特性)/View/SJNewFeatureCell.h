//
//  SJNewFeatureCell.h
//  CaiShiJie
//
//  Created by user on 15/12/22.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJNewFeatureCell : UICollectionViewCell

@property (nonatomic, copy) NSString *imageName;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)setIndexPath:(NSIndexPath *)indexPath pagecount:(NSInteger)pagecount;

@end

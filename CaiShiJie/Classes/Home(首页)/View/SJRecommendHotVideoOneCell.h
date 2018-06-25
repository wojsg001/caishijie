//
//  SJRecommendHotVideoOneCell.h
//  CaiShiJie
//
//  Created by user on 18/5/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RecommendHotVideoBlock)(NSInteger index);

@interface SJRecommendHotVideoOneCell : UITableViewCell

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, copy) RecommendHotVideoBlock recommendHotVideoBlock;

@end

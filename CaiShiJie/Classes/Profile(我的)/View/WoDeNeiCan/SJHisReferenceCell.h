//
//  SJHisReferenceCell.h
//  CaiShiJie
//
//  Created by user on 16/3/24.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMyNeiCan;
@protocol SJHisReferenceCellDelegate <NSObject>

- (void)didClickPayButtonWith:(SJMyNeiCan *)model;

@end

@interface SJHisReferenceCell : UITableViewCell

@property (nonatomic, strong) SJMyNeiCan *hisReference;

@property (nonatomic, weak) id<SJHisReferenceCellDelegate>delegate;

@end

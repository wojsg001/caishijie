//
//  SJPhoneVideoListViewController.h
//  CaiShiJie
//
//  Created by user on 16/12/2.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@class SJPhoneVideoListModel;
@interface SJPhoneVideoListCell : UICollectionViewCell

@property (nonatomic, strong) SJPhoneVideoListModel *model;

@end

@interface SJPhoneVideoListViewController : SJBaseViewController

- (void)refresh;

@end

//
//  SJPhoneVideoListViewController.h
//  CaiShiJie
//
//  Created by user on 18/12/2.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@class SJPhoneVideoListModel;
@interface SJPhoneVideoListCell : UICollectionViewCell

@property (nonatomic, strong) SJPhoneVideoListModel *model;

@end

@interface SJPhoneVideoListViewController : SJBaseViewController

- (void)refresh;

@end

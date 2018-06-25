//
//  SJPersonalSummaryViewController.h
//  CaiShiJie
//
//  Created by user on 18/9/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBaseViewController.h"

@interface SJPersonalSummarySectionView : UIView

@property (nonatomic, strong) NSDictionary *dic;

@end

@interface SJPersonalSummaryViewController : SJBaseViewController

@property (nonatomic, copy) NSString *target_id;

@end

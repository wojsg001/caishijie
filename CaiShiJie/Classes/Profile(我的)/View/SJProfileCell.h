//
//  SJProfileCell.h
//  CaiShiJie
//
//  Created by user on 15/12/29.
//  Copyright © 2015年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setBadgeValueHidden:(BOOL)hidden;

@end

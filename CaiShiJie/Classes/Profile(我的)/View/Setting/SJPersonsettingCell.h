//
//  SJPersonsettingCell.h
//  CaiShiJie
//
//  Created by user on 18/4/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJPersonsettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic,assign)BOOL isselected;
@end

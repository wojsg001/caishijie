//
//  SJsearchCell.h
//  CaiShiJie
//
//  Created by user on 16/5/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJsearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *btn;
- (IBAction)Btncilck:(UIButton *)sender;


@end

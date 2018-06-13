//
//  SJMasterTeacherCell.h
//  CaiShiJie
//
//  Created by user on 16/5/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJMasterTeacherCell;
@protocol SJMasterTeacherCellDelegate <NSObject>

- (void)masterTeacherCell:(SJMasterTeacherCell *)masterTeacherCell didSelectedwhichOne:(NSInteger)index;

@end

@interface SJMasterTeacherCell : UITableViewCell

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, weak) id<SJMasterTeacherCellDelegate>delegate;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

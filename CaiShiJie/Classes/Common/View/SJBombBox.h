//
//  SJBombBox.h
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJBombBoxDelegate <NSObject>

- (void)respondClickEvent:(NSInteger)index;

@end

@interface SJBombBox : UIView

@property (nonatomic, weak) id<SJBombBoxDelegate> delegate;

@end

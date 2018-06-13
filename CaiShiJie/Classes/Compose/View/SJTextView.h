//
//  SJTextView.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJTextView : UITextView

@property (nonatomic, copy) NSString *placeHolder;

@property (nonatomic, assign) BOOL hidePlaceHolder;
@property (nonatomic, assign) CGFloat placeHolderLabelX;
@property (nonatomic, assign) CGFloat placeHolderLabelY;

@end

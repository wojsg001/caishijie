//
//  SJBookDetailFootView.h
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJBookDetailFootViewDelegate <NSObject>

- (void)firstPageBtnClickDown;
- (void)beforePageBtnClickDown;
- (void)nextPageBtnClickDown;
- (void)lastPageBtnClickDown;

@end

@interface SJBookDetailFootView : UIView

@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UILabel *allPageLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstPageBtn;
@property (weak, nonatomic) IBOutlet UIButton *beforePageBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextPageBtn;
@property (weak, nonatomic) IBOutlet UIButton *lastPageBtn;

@property (nonatomic, weak) id<SJBookDetailFootViewDelegate>delegate;

@end

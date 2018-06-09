//
//  SJselfSelectedDefaultController.h
//  CaiShiJie
//
//  Created by user on 16/5/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJselfSelectedDefaultController;
@protocol SJselfSelectedDefaultControllerdelegate <NSObject>

-(void)btnclick:(UIButton *)btn;

@end

@interface SJselfSelectedDefaultController : UIViewController

@property (nonatomic, assign)id<SJselfSelectedDefaultControllerdelegate>delegate;
- (IBAction)zhuceBtn:(UIButton *)sender;
- (IBAction)loginBtn:(UIButton *)sender;

@end

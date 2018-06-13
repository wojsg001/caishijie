//
//  SJComposeViewController.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJComposeViewController : SJBaseViewController

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *targetid;
@property (nonatomic, copy) NSString *itemid;
/**
 *  区别是回答问题还是提问问题, 0代表提问问题, 1代表回答问题
 */
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) void(^refreshData)(BOOL);

@end

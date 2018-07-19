//
//  UIViewController+BackButtonHandler.h
//  PLTest
//
//  Created by mac on 2017/12/9.
//  Copyright © 2017年 腾飞. All rights reserved.
//  参考：http://stackoverflow.com/questions/1214965/setting-action-for-back-button-in-navigation-controller/19132881#19132881
//=========获取导航栏的返回事件，重写下面这个方法，当点击返回按钮时做一些处理==============
//-(BOOL) navigationShouldPopOnBackButton {
//    if(needsShowConfirmation) {
//        // Show confirmation alert
//        // ...
//        return NO; // Ignore 'Back' button this time
//    }
//    return YES; // Process 'Back' button click and Pop view controler
//}

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end

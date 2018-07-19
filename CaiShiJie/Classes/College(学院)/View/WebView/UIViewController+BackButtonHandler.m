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

#import "UIViewController+BackButtonHandler.h"

@implementation UIViewController (BackButtonHandler)

@end

@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {

	if([self.viewControllers count] < [navigationBar.items count]) {
		return YES;
	}

	BOOL shouldPop = YES;
	UIViewController* vc = [self topViewController];
	if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
		shouldPop = [vc navigationShouldPopOnBackButton];
	}

	if(shouldPop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self popViewControllerAnimated:YES];
		});
	} else {

		for(UIView *subview in [navigationBar subviews]) {
			if(0. < subview.alpha && subview.alpha < 1.) {
				[UIView animateWithDuration:.25 animations:^{
					subview.alpha = 1.;
				}];
			}
		}
	}

	return NO;
}

@end

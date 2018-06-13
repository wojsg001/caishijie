//
//  SJBlogArticleView.h
//  CaiShiJie
//
//  Created by user on 16/4/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJBlogArticleTypeViewDelegate <NSObject>

- (void)didClickWhichOneButton:(NSInteger)index;

@end

@interface SJBlogArticleTypeView : UIView

@property (nonatomic, weak) id<SJBlogArticleTypeViewDelegate>delegate;
@property (nonatomic, strong) NSArray *typeArr;

@end

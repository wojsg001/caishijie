//
//  SJAddReferenceContentView.h
//  CaiShiJie
//
//  Created by user on 16/3/30.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJAddReferenceContentViewDelegate <NSObject>

- (void)didClickAddImageButton;

@end

@interface SJAddReferenceContentView : UIView

@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (nonatomic, weak) id<SJAddReferenceContentViewDelegate>delegate;

@property (nonatomic, strong) NSArray *imageArr;

@end

//
//  SJCollectionHeadview.h
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJCollectionHeadview;
@protocol SJCollectionHeadviewdelegate <NSObject>

-(void)btnclick:(UIButton *)sender;

@end



@interface SJCollectionHeadview : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *lable;
@property (weak, nonatomic) IBOutlet UIButton *Morebtn;
@property (nonatomic,assign) id<SJCollectionHeadviewdelegate>delegate;
- (IBAction)MoreBtn:(UIButton *)sender;

@end

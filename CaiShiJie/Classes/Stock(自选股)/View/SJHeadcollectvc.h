//
//  SJHeadcollectvc.h
//  CaiShiJie
//
//  Created by user on 16/5/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJHeadcollectvc;
@protocol SJHeadcollectvcdelegate <NSObject>
-(void)morebtnClick:(UIButton *)btn;


@end
@interface SJHeadcollectvc : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIButton *Morebtn;
@property (weak, nonatomic) IBOutlet UILabel *namelable;
@property (assign,nonatomic)id<SJHeadcollectvcdelegate>delegate;
- (IBAction)Morebtnclick:(UIButton *)sender;

@end

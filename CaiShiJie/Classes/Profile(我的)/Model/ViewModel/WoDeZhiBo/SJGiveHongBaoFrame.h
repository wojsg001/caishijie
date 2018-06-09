//
//  SJGiveHongBaoFrame.h
//  CaiShiJie
//
//  Created by user on 16/8/18.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJGiveGiftModel;
@interface SJGiveHongBaoFrame : NSObject

@property (nonatomic,assign) CGRect iconF;
@property (nonatomic,assign) CGRect timeF;
@property (nonatomic,assign) CGRect titleF;
@property (nonatomic,assign) CGRect statePictureF;
@property (nonatomic,assign) CGRect contentPictureF;
@property (nonatomic,assign) CGRect bgBtnF;
@property (nonatomic,assign) CGFloat cellH;

@property (nonatomic, strong) SJGiveGiftModel *giveGiftModel;

@end

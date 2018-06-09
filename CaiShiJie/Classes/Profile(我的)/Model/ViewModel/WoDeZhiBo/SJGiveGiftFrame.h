//
//  SJGiveGiftFrame.h
//  CaiShiJie
//
//  Created by user on 16/3/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJGiveGiftModel;
@interface SJGiveGiftFrame : NSObject

@property (nonatomic,assign) CGRect iconF;
@property (nonatomic,assign) CGRect timeF;
@property (nonatomic,assign) CGRect titleF;
@property (nonatomic,assign) CGRect contentF;
@property (nonatomic,assign) CGRect pictureF;
@property (nonatomic,assign) CGRect bgBtnF;
@property (nonatomic,assign) CGFloat cellH;

@property (nonatomic, strong) SJGiveGiftModel *giveGiftModel;

@end

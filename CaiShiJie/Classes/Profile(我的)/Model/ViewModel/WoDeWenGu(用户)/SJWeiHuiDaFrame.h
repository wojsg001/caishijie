//
//  SJWeiHuiDaFrame.h
//  CaiShiJie
//
//  Created by user on 16/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJWeiHuiDaModel, TYTextContainer;
@interface SJWeiHuiDaFrame : NSObject

@property (nonatomic, strong) TYTextContainer *contentTextContainer;

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect questionF;
@property (nonatomic, assign) CGRect lineViewF;

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,strong) SJWeiHuiDaModel *questionModel;

@end

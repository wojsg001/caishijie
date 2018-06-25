//
//  SJYiJingHuiDaFrame.h
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SJYiJingHuiDaModel, TYTextContainer;
@interface SJYiJingHuiDaFrame : NSObject

@property (nonatomic, strong) TYTextContainer *contentTextContainer;
@property (nonatomic, strong) TYTextContainer *answerTextContainer;

@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect levelF;
@property (nonatomic, assign) CGRect timeF;
@property (nonatomic, assign) CGRect answerF;
@property (nonatomic, assign) CGRect line1ViewF;
@property (nonatomic, assign) CGRect questionF;
@property (nonatomic, assign) CGRect countF;
@property (nonatomic, assign) CGRect bottomViewF;

@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,strong) SJYiJingHuiDaModel *YiJingHuiDaModel;

@end

//
//  SJTextContainerParser.h
//  CaiShiJie
//
//  Created by user on 16/8/16.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYTextContainer;
@interface SJTextContainerParser : NSObject

+ (TYTextContainer *)getTextContainerWithContent:(NSString *)content;

@end

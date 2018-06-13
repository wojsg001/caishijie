//
//  SJFaceHandler.h
//  CaiShiJie
//
//  Created by user on 16/10/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJFaceHandler : NSObject

+ (instancetype)sharedFaceHandler;
- (void)initPlist;
- (NSArray *)getComputerFaceArray;
- (NSArray *)getPhoneFaceArray;
- (NSDictionary *)getPhoneFaceDictionary;

@end

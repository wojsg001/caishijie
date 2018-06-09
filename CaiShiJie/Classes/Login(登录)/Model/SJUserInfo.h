//
//  SJUserInfo.h
//  CaiShiJie
//
//  Created by user on 15/12/30.
//  Copyright © 2015年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJUserInfo : NSObject

+ (SJUserInfo *)sharedUserInfo;

//是否成功登陆过
- (BOOL)isSucessLogined;

//普通登陆
- (void)loginWithUserName:(NSString *)user
              andPassword:(NSString *)pwd
         withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
             andFailBlock:(void (^)(NSError *error))failBlock;

//第三方登陆
- (void)loginWithType:(NSString *)type
              andOpenid:(NSString *)openid
         withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
             andFailBlock:(void (^)(NSError *error))failBlock;

@end

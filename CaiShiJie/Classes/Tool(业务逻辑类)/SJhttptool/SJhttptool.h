//
//  SJhttptool.h
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJhttptool : NSObject

+(void)GET:(NSString *)url paramers:(id)paramers success:(void(^)(id respose))success failure:(void(^)(NSError *error))failure;
+(void)POST:(NSString *)url paramers:(id)paramers success:(void(^)(id respose))success failure:(void(^)(NSError *error))failure;

@end

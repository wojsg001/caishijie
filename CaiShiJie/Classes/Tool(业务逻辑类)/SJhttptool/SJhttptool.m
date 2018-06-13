//
//  SJhttptool.m
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJhttptool.h"
#import "AFNetworking.h"

@implementation SJhttptool

+(void)GET:(NSString *)url paramers:(id)paramers success:(void(^)(id respose))success failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 10.0; // 超时时间
    [manager GET:url parameters:paramers progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+(void)POST:(NSString *)url paramers:(id)paramers success:(void(^)(id respose))success failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    [manager POST:url parameters:paramers progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end

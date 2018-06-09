//
//  SJUserInfo.m
//  CaiShiJie
//
//  Created by user on 15/12/30.
//  Copyright © 2015年 user. All rights reserved.
//

#import "SJUserInfo.h"

#import "AFNetworking.h"

static SJUserInfo *instance = nil;

@implementation SJUserInfo

+ (SJUserInfo *)sharedUserInfo
{
    if (instance == nil)
    {
        instance = [[SJUserInfo alloc]init];
    }
    return instance;
}

//是否成功登陆过
- (BOOL)isSucessLogined
{
    return [SJUserDefaults boolForKey:kSuccessLogined];
}

//登陆
- (void)loginWithUserName:(NSString *)user
              andPassword:(NSString *)pwd
         withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
             andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/login/index",HOST];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    // 构建请求参数
    NSDictionary *dict = @{@"nickname":user,@"loginpwd":pwd};
    [manager POST:urlStr parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        successBlock(tmpDict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock(error);
    }];
}

- (void)loginWithType:(NSString *)type
            andOpenid:(NSString *)openid
     withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
         andFailBlock:(void (^)(NSError *error))failBlock
{
   
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/login/oauth",HOST];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    // 构建请求参数
    NSDictionary *dict = @{@"type":type,@"openid":openid};
    
    [manager POST:urlStr parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        successBlock(tmpDict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock(error);
    }];
}

@end

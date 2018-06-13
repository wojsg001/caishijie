//
//  SJToken.m
//  CaiShiJie
//
//  Created by user on 16/4/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJToken.h"
#import "NSString+SJMD5.h"



@implementation SJToken

+ (SJToken *)sharedToken
{
    SJToken *instance = [[SJToken alloc] init];
    
    NSString *user_id = [SJUserDefaults valueForKey:kUserid];
    NSString *auth_key = [SJUserDefaults valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    // md5加密成得到token
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    instance.token = md5Auth_key;
    instance.userid = user_id;
    instance.time = datestr;

    return instance;
}

@end

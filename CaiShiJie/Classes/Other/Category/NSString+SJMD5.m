//
//  NSString+SJMD5.m
//  CaiShiJie
//
//  Created by user on 18/1/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "NSString+SJMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SJMD5)

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end

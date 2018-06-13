//
//  QNNExternalIp.h
//  NetDiag
//
//  Created by bailong on 16/1/26.
//  Copyright © 2018年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNNExternalIp : NSObject

+ (NSString*)externalIp;
+ (NSString*)externalDNS;

+ (NSString*)checkExternal;

@end

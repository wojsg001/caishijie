//
//  SJToken.h
//  CaiShiJie
//
//  Created by user on 18/4/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJToken : NSObject

+ (SJToken *)sharedToken;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *time;


@end

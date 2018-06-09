//
//  SJSenderModel.m
//  CaiShiJie
//
//  Created by user on 16/3/8.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJSenderModel.h"
#import "MJExtension.h"
#import "SJGiftGeterModel.h"

@implementation SJSenderModel

- (void)setSeller:(NSDictionary *)seller
{
    _seller = seller;
    
    _giftGeterModel = [SJGiftGeterModel objectWithKeyValues:_seller];
    if ([_price floatValue] < KBigHongBao) {
        _hongbao = [NSString stringWithFormat:@"%@给%@送红包", _nickname, _giftGeterModel.nickname];
    } else {
        _hongbao = [NSString stringWithFormat:@"%@给%@送", _nickname, _giftGeterModel.nickname];
    }
}

@end

//
//  SJMixPayParam.h
//  CaiShiJie
//
//  Created by user on 16/3/22.
//  Copyright © 2016年 user. All rights reserved.
//
//混合支付参数
#import <Foundation/Foundation.h>

@interface SJMixPayParam : NSObject
/*
 token：秘钥
 userid ：登录用户
 time：生成秘钥时间
 targetid:收礼物的人
 itemname：礼物名称
 itemid ：礼物ID
 itemtype :礼物类型【1：礼物,2:红包，3：上香，20：内参,0:充值】
 price :礼物单价
 itemcount ：礼物数量
 paytype：支付类型【微信:WX_APP, 支付宝：ALI_APP 】
 paygold：支付金额
  
 */
@property (nonatomic,copy)NSString *token;
@property (nonatomic,copy)NSString *userid;
@property (nonatomic,copy)NSString *time;
@property (nonatomic,copy)NSString *targetid;
@property (nonatomic,copy)NSString *itemname;
@property (nonatomic,copy)NSString *itemid;
@property (nonatomic,copy)NSString *itemtype;
@property (nonatomic,copy)NSString *price;
@property (nonatomic,copy)NSString *itemcount;
@property (nonatomic,copy)NSString *paytype;
@property (nonatomic,copy)NSString *paygold;


@end

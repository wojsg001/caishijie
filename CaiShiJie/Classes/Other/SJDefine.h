//
//  SJDefine.h
//  CaiShiJie
//
//  Created by user on 18/3/18.
//  Copyright © 2018年 user. All rights reserved.
//

#ifndef SJDefine_h
#define SJDefine_h

#define kUserName       @"userName"
#define kPassword       @"password"
#define kType           @"type"
#define kOpenid         @"openid"
#define kUserid         @"userid"
#define kSuccessLogined @"SuccessLogined"
#define kLoginType      @"other"
#define kAuth_key       @"auth_key"
#define kUserInfo       @"userInfo"
#define kAdUrlStr       @"adUrlStr"

#define kHead_imgURL   @"http://img.csjimg.com/"   // 头像地址
#define kScroll_imgURL @"http://common.csjimg.com" // 滚动图地址
//#define kVideo_imgURL  @"http://img.csjvod.com"    // 视频图片地址

//#if DEBUG  // 调试状态
//    #define HOST     @"http://192.168.6.110:8081"  // 服务器地址
//    #define imHost   @"192.168.6.110:8082"         // web服务器地址
//    #define MQTTHost @"192.168.6.110"
//#else      // 发布状态
    #define HOST     @"http://www.18csj.com" // 服务器地址
    //#define imHost   @"im.csjapi.com"        // web服务器地址
    #define imHost   @"180.169.46.148:9502"        // web服务器地址 即时通讯
    #define MQTTHost @"mqtt.18csj.com"
//#endif

#define UMENG_APPKEY @"5b1f2ca2f43e48145e0000ac" //友盟appKey

#define KNotificationMarketIndex         @"MarketIndex"

#define KNotificationLoadOpinion          @"loadOpinion"
#define KNotificationLoadInteract         @"loadInteract"

#define KNotificationAddOpinion           @"addOpinion"
#define KNotificationAddInteract          @"addInteract"
#define KNotificatioNInteractRefresh      @"interactRefresh"
#define KNotificatioNInteractGroupChat    @"interactGroupChat"

#define KNotificationAddLunXunOpinion     @"addLunXunOpinion"
#define KNotificationAddLunXUnInteract    @"addLunXunInteract"

#define KNotificationResignFirstResponder @"resignFirstResponder"
#define KNotificationTextFieldStopEdit    @"TextFieldStopEdit"
#define KNotificationTextFieldAllowEdit   @"TextFieldAllowEdit"

#define KNotificationLoginSuccess         @"LoginSuccess"
#define KNotificationExitLogin            @"ExitLogin"

#define KNotificationNetworkStatusChange  @"NetworkStatusChange"
#define KNotificationRefreshStockData     @"RefreshStockData"

#define KNotificationMQTTHaveNewData          @"MQTTHaveNewData"
#define KNotificationChatMessageUnreadCount   @"ChatMessageUnreadCount"

#define KBigHongBao 200
#define KPayViewTag 8888
#define KGiftPayViewTag 9999

// 判断是否相等
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
// 判断是否大于
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
// 判断是否大于或等于
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
// 判断是否小余
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#define NonEmptyString(a)    (a == nil || [a isKindOfClass:[NSNull class]] || a == NULL) ? @"" :a
// 是否为NSDictionary，并且是否为空
#define NSDictionaryMatchAndCount(ownOBJ)    ([ownOBJ isKindOfClass:[NSDictionary class]] && ((NSDictionary *)ownOBJ).allKeys.count > 0)
// 是否为NSArray，并且是否为空
#define NSArrayMatchAndCount(ownOBJ)    ([ownOBJ isKindOfClass:[NSArray class]] && ((NSArray *)ownOBJ).count > 0)
/// 仅支持value为String类型
#define NSDictionaryContentWithKey(dic, key)  [NSString stringWithFormat:@"%@", NonEmptyString([dic objectForKey:key])]

#endif /* SJDefine_h */

//
//  SJNetManager.h
//  CaiShiJie
//
//  Created by user on 18/1/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJMixPayParam.h"

@class SJUploadParam,SJGoldPay,SJUserConsumeParam,SJBuyGoldParam,SJMixPayParam;
@interface SJNetManager : NSObject

+ (SJNetManager *)sharedNetManager;

//请求推荐日志数据
- (void)requestRecommendLogDataWithPage:(NSString *)page
                        andPageSize:(NSString *)pageSize
                   withSuccessBlock:(void (^)(NSArray *arr))successBlock
                       andFailBlock:(void (^)(NSError *error))failBlock;

//请求推荐高手数据
- (void)requestRecommendMasterDataWithPage:(NSString *)page
                            andPageSize:(NSString *)pageSize
                       withSuccessBlock:(void (^)(NSArray *arr))successBlock
                           andFailBlock:(void (^)(NSError *error))failBlock;

//添加关注
- (void)addAttentionWithToken:(NSString *)token
                    andUserid:(NSString *)userid
                      andTime:(NSString *)time
                   andTargetid:(NSString *)targetid
              withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                  andFailBlock:(void (^)(NSError *error))failBlock;

//请求文章详情数据
- (void)requestLogDetailDataWithUrlStr:(NSString *)urlStr
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock;

//请求直播主题
- (void)requestLiveTitleWithToken:(NSString *)token
                        andUserid:(NSString *)userid
                          andTime:(NSString *)time
                       andTargetid:(NSString *)targetid
                         andLiveid:(NSString *)liveid
                         withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                             andFailBlock:(void (^)(NSError *error))failBlock;

//请求观点和互动
- (void)requestViewAndInteractionWithUserid:(NSString *)userid
                                  andLiveid:(NSString *)liveid
                               andPageindex:(NSString *)pageindex
                                andPageSize:(NSString *)pagesize
                  withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                      andFailBlock:(void (^)(NSError *error))failBlock;

// 发送观点
- (void)sendOpinionWithToken:(NSString *)token
                   andUserid:(NSString *)userid
                     andTime:(NSString *)time
                 andTargetid:(NSString *)targetid
                  andContent:(NSString *)content
                     success:(void (^)(NSDictionary *dict))success
                     failure:(void (^)(NSError *error))failure;

// 发送互动
- (void)sendInteractionWithToken:(NSString *)token
                       andUserid:(NSString *)userid
                         andTime:(NSString *)time
                     andTargetid:(NSString *)targetid
                      andContent:(NSString *)content
                      andReplyid:(NSString *)replyid
                         success:(void (^)(NSDictionary *dict))success
                         failure:(void (^)(NSError *error))failure;

// 加载向上观点
- (void)requestMoreOldOpinionWithUserid:(NSString *)userid
                              andLiveid:(NSString *)liveid
                                  andSn:(NSString *)sn
                                andPageSize:(NSString *)pagesize
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock;

// 加载向上互动
- (void)requestMoreOldInteractionWithUserid:(NSString *)userid
                              andLiveid:(NSString *)liveid
                                  andSn:(NSString *)sn
                            andPageSize:(NSString *)pagesize
                       withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                           andFailBlock:(void (^)(NSError *error))failBlock;

// 请求关注列表
- (void)requestAttentionListWithUserid:(NSString *)userid
                                  andPageindex:(NSString *)pageindex
                                andPageSize:(NSString *)pagesize
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock;

// 请求博文列表
- (void)requestBlogArticleListWithPageindex:(NSString *)pageindex
                                andPagesize:(NSString *)pagesize
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock;

// 请求问股列表(我的咨询记录)
- (void)requestMyQuestionListWithUserid:(NSString *)userid
                           andPageindex:(NSString *)pageindex
                            andPagesize:(NSString *)pagesize
                              andAnswer:(NSString *)answer
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock;
// 请求用户问股详情数据
- (void)requestMyQuestionDetailListWithItemid:(NSString *)itemid
                          andPageindex:(NSString *)pageindex
                           andPageSize:(NSString *)pagesize
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock;

// 请求我的投顾列表
- (void)requestMyTeacherListWithUserid:(NSString *)userid
                          andPageindex:(NSString *)pageindex
                           andPageSize:(NSString *)pagesize
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock;

// 请求普通用户的内参列表
- (void)requestMyNeiCanListWithUserid:(NSString *)userid
                          andPageindex:(NSString *)pageindex
                           andPageSize:(NSString *)pagesize
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock;

// 请求投顾的内参列表
- (void)requestTeacherNeiCanListWithUserid:(NSString *)userid
                         andPageindex:(NSString *)pageindex
                          andPageSize:(NSString *)pagesize
                     withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                         andFailBlock:(void (^)(NSError *error))failBlock;
// 给文章点赞或取消点赞
- (void)giveArticlePraiseWithToken:(NSString *)token
                         andUserid:(NSString *)userid
                           andTime:(NSString *)time
                          andItemid:(NSString *)articleid
                   withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                       andFailBlock:(void (^)(NSError *error))failBlock;

// 发送问股
- (void)sendQuestionWithToken:(NSString *)token
                    andUserid:(NSString *)userid
                      andTime:(NSString *)time
                  andTargetid:(NSString *)targetid
                   andContent:(NSString *)content;

// 轮训请求数据
- (void)lunXunRequestDataWithUserid:(NSString *)userid
                        andTargetid:(NSString *)targetid
                              andSn:(NSString *)sn
                   withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                       andFailBlock:(void (^)(NSError *error))failBlock;

// 上传图片
- (void)uploadImageWithUploadParam:(SJUploadParam *)uploadParam
                           success:(void (^)(NSDictionary *dict))success
                           failure:(void (^)(NSError *error))failure;

// 请求礼物列表信息
- (void)requestGiftListInfoSuccess:(void (^)(NSDictionary *dict))success
                           failure:(void (^)(NSError *error))failure;

// 金币支付接口
- (void)goldToPayWithParam:(SJGoldPay *)golePayParam
                   success:(void (^)(NSDictionary *dict))success
                   failure:(void (^)(NSError *error))failure;

// 获取投顾收益
- (void)getTeacherEarningsWithToken:(NSString *)token
                          andUserId:(NSString *)userId
                            andTime:(NSString *)time
                        andStart_at:(NSString *)start_at
                          andEnd_at:(NSString *)end_at
                   success:(void (^)(NSDictionary *dict))success
                   failure:(void (^)(NSError *error))failure;

// 获取用户消费记录账单
- (void)requestUserConsumeWithParam:(SJUserConsumeParam *)consumeParam
                            success:(void (^)(NSDictionary *dict))success
                            failure:(void (^)(NSError *error))failure;

// 金币充值，获取订单ID
- (void)buyGoldWithSJBuyGoldParam:(SJBuyGoldParam *)buyGoldParam
                 success:(void (^)(NSDictionary *dict))success
                 failure:(void (^)(NSError *error))failure;

// 打开视频直播
- (void)openVideoWithDict:(NSDictionary *)dict
                   success:(void (^)(NSDictionary *dict))success
                   failure:(void (^)(NSError *error))failure;

// 获取获取SDK直播操作token
- (void)requestVideoLiveAccessTokensuccess:(void (^)(NSDictionary *dict))success
                                   failure:(void (^)(NSError *error))failure;

//请求个人文章
- (void)requestPersonalArticleListWithPageindex:(NSString *)pageindex
                                    andPagesize:(NSString *)pagesize
                                      anduserid:(NSString *)userid
                               withSuccessBlock:(void (^)(id dict))successBlock
                                   andFailBlock:(void (^)(NSError *error))failBlock;

//混合支付方式
-(void)mixPaywithSJMixPayParam:(SJMixPayParam *)MixPayParam success:(void (^)(NSDictionary *dict))success failure:(void (^)(NSError *error))failure;


// 请求用户内参详情
- (void)requestUserReferenceDetailWithUserid:(NSString *)user_id
                             andReferenceid:(NSString *)referenceid
                                    success:(void (^)(NSDictionary *dict))success
                                    failure:(void (^)(NSError *error))failure;

// 修改内参价格
- (void)modifyReferencePriceWithDict:(NSDictionary *)dict
                             success:(void (^)(NSDictionary *dict))success
                             failure:(void (^)(NSError *error))failure;

// 修改内参服务结束时间
- (void)modifyReferenceServiceDateWith:(NSDictionary *)dict
                               success:(void (^)(NSDictionary *dict))success
                               failure:(void (^)(NSError *error))failure;

// 停止内参销售
- (void)stopSellReferenceWithDict:(NSDictionary *)dict
                          success:(void (^)(NSDictionary *dict))success
                          failure:(void (^)(NSError *error))failure;

//请求视频地址
- (void)GetvideodetailWithDict:(NSDictionary *)dict
                       success:(void (^)(NSDictionary *dict))success
                       failure:(void (^)(NSError *error))failure;

//请求问答
- (void)GetQuestionAndAnswerWithDict:(NSDictionary *)dict
                             success:(void (^)(NSDictionary *dict))success
                             failure:(void (^)(NSError *error))failure;

@end

//
//  SJNetManager.m
//  CaiShiJie
//
//  Created by user on 16/1/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJNetManager.h"
#import "SJhttptool.h"
#import "MBProgressHUD+MJ.h"
#import "SJUploadParam.h"
#import "SJGoldPay.h"
#import "SJUserConsumeParam.h"
#import "MJExtension.h"
#import "SJBuyGoldParam.h"
#import "AFNetworking.h"

static SJNetManager *instance = nil;

@implementation SJNetManager

+ (SJNetManager *)sharedNetManager
{
    @synchronized(self)
    {
        if(!instance)
        {
            instance = [[SJNetManager alloc] init];
        }
    }
    return instance;
}

- (void)requestRecommendLogDataWithPage:(NSString *)page
                            andPageSize:(NSString *)pageSize
                       withSuccessBlock:(void (^)(NSArray *arr))successBlock
                           andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/recommend/article?page=%@&pageSize=%@",HOST,page,pageSize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //SJLog(@"%@",urlStr);
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestRecommendMasterDataWithPage:(NSString *)page
                               andPageSize:(NSString *)pageSize
                          withSuccessBlock:(void (^)(NSArray *arr))successBlock
                              andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/recommend/master?page=%@&pageSize=%@",HOST,page,pageSize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)addAttentionWithToken:(NSString *)token
                    andUserid:(NSString *)userid
                      andTime:(NSString *)time
                   andTargetid:(NSString *)targetid
              withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                  andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/attention",HOST];
    NSDictionary *dict = @{@"userid":userid,@"targetid":targetid,@"token":token,@"time":time};
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        successBlock(respose);
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestLogDetailDataWithUrlStr:(NSString *)urlStr
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock
{
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        successBlock(respose);
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestLiveTitleWithToken:(NSString *)token
                        andUserid:(NSString *)userid
                          andTime:(NSString *)time
                      andTargetid:(NSString *)targetid
                        andLiveid:(NSString *)liveid
                 withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                     andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live?token=%@&userid=%@&time=%@&targetid=%@&liveid=%@",HOST,token,userid,time,targetid,liveid];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        successBlock(respose);
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestViewAndInteractionWithUserid:(NSString *)userid
                                  andLiveid:(NSString *)liveid
                               andPageindex:(NSString *)pageindex
                                andPageSize:(NSString *)pagesize
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/message?userid=%@&liveid=%@&pageindex=%@&pagesize=%@",HOST,userid,liveid,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}
// 发送观点
- (void)sendOpinionWithToken:(NSString *)token
                   andUserid:(NSString *)userid
                     andTime:(NSString *)time
                 andTargetid:(NSString *)targetid
                  andContent:(NSString *)content
                     success:(void (^)(NSDictionary *dict))success
                     failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/sendliveview",HOST];
    NSDictionary *dict = @{@"token":token,@"userid":userid,@"time":time,@"targetid":targetid,@"content":content};
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

// 发送互动
- (void)sendInteractionWithToken:(NSString *)token
                       andUserid:(NSString *)userid
                         andTime:(NSString *)time
                     andTargetid:(NSString *)targetid
                      andContent:(NSString *)content
                      andReplyid:(NSString *)replyid
                         success:(void (^)(NSDictionary *dict))success
                         failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/sendinteraction",HOST];
    NSDictionary *dict = @{@"token":token,@"userid":userid,@"time":time,@"targetid":targetid,@"content":content,@"replyid":replyid};
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)requestMoreOldOpinionWithUserid:(NSString *)userid
                              andLiveid:(NSString *)liveid
                                  andSn:(NSString *)sn
                            andPageSize:(NSString *)pagesize
                       withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                           andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/upopinion?userid=%@&liveid=%@&sn=%@&pagesize=%@",HOST,userid,liveid,sn,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

// 加载向上互动
- (void)requestMoreOldInteractionWithUserid:(NSString *)userid
                                  andLiveid:(NSString *)liveid
                                      andSn:(NSString *)sn
                                andPageSize:(NSString *)pagesize
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/upinteract?userid=%@&liveid=%@&sn=%@&pagesize=%@",HOST,userid,liveid,sn,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestAttentionListWithUserid:(NSString *)userid
                          andPageindex:(NSString *)pageindex
                           andPageSize:(NSString *)pagesize
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/attentionall?userid=%@&pageindex=%@&pagesize=%@",HOST,userid,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestBlogArticleListWithPageindex:(NSString *)pageindex
                                andPagesize:(NSString *)pagesize
                           withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                               andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/all?pageindex=%@&pagesize=%@",HOST,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestMyQuestionListWithUserid:(NSString *)userid
                           andPageindex:(NSString *)pageindex
                            andPagesize:(NSString *)pagesize
                              andAnswer:(NSString *)answer
                       withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                           andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/question/myall?userid=%@&pageindex=%@&pagesize=%@&answer=%@",HOST,userid,pageindex,pagesize,answer];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //SJLog(@"+++%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

// 请求用户详情数据
- (void)requestMyQuestionDetailListWithItemid:(NSString *)itemid
                                 andPageindex:(NSString *)pageindex
                                  andPageSize:(NSString *)pagesize
                             withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                                 andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/question/detail?itemid=%@&pageindex=%@&pagesize=%@",HOST,itemid,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestMyTeacherListWithUserid:(NSString *)userid
                          andPageindex:(NSString *)pageindex
                           andPageSize:(NSString *)pagesize
                      withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                          andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/attentionmanage?userid=%@&pageindex=%@&pagesize=%@",HOST,userid,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestMyNeiCanListWithUserid:(NSString *)userid
                         andPageindex:(NSString *)pageindex
                          andPageSize:(NSString *)pagesize
                     withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                         andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/pay?userid=%@&pageindex=%@&pagesize=%@",HOST,userid,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)requestTeacherNeiCanListWithUserid:(NSString *)userid
                              andPageindex:(NSString *)pageindex
                               andPageSize:(NSString *)pagesize
                          withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                              andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/my?userid=%@&pageindex=%@&pagesize=%@",HOST,userid,pageindex,pagesize];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)giveArticlePraiseWithToken:(NSString *)token
                         andUserid:(NSString *)userid
                           andTime:(NSString *)time
                          andItemid:(NSString *)articleid
                   withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                       andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/praise",HOST];
    NSDictionary *dict = @{@"token":token,@"itemid":articleid,@"userid":userid,@"time":time};
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        successBlock(respose);
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
        failBlock(error);
    }];
}

- (void)sendQuestionWithToken:(NSString *)token
                    andUserid:(NSString *)userid
                      andTime:(NSString *)time
                  andTargetid:(NSString *)targetid
                   andContent:(NSString *)content
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/sendquestion",HOST];
    NSDictionary *dict = @{@"token":token,@"userid":userid,@"time":time,@"targetid":targetid,@"content":content};
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            [MBProgressHUD showSuccess:@"提问成功!"];
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)lunXunRequestDataWithUserid:(NSString *)userid
                        andTargetid:(NSString *)targetid
                              andSn:(NSString *)sn withSuccessBlock:(void (^)(NSDictionary *dict))successBlock
                       andFailBlock:(void (^)(NSError *error))failBlock
{
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/lp?u=%@&l=%@&sn=%@",imHost,userid,targetid,sn];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        successBlock(respose);
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

- (void)uploadImageWithUploadParam:(SJUploadParam *)uploadParam
                           success:(void (^)(NSDictionary *dict))success
                           failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"http://www.18csj.com/upload/img"];
    //SJLog(@"%@",urlStr);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /**
         *  FileData:要上传的文件的二进制数据
         *  name:上传参数名称
         *  fileName：上传到服务器的文件名称
         *  mimeType：文件类型
         */
        [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            success(tmpDict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            [MBHUDHelper showWarningWithText:error.localizedDescription];
            failure(error);
        }
    }];
}

- (void)requestGiftListInfoSuccess:(void (^)(NSDictionary *dict))success
                           failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/gift/index",HOST];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            success(respose[@"data"]);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)goldToPayWithParam:(SJGoldPay *)golePayParam
                   success:(void (^)(NSDictionary *dict))success
                   failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/pay/directlypaygift",HOST];
    //SJLog(@"%@",urlStr);
    [SJhttptool POST:urlStr paramers:golePayParam.keyValues success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getTeacherEarningsWithToken:(NSString *)token
                          andUserId:(NSString *)userId
                            andTime:(NSString *)time
                        andStart_at:(NSString *)start_at
                          andEnd_at:(NSString *)end_at
                            success:(void (^)(NSDictionary *dict))success
                            failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/pay/earnings?token=%@&userid=%@&time=%@&start_at=%@&end_at=%@",HOST,token,userId,time,start_at,end_at];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            success(respose[@"data"]);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)requestUserConsumeWithParam:(SJUserConsumeParam *)consumeParam
                            success:(void (^)(NSDictionary *dict))success
                            failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/pay/findpay",HOST];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [SJhttptool GET:urlStr paramers:consumeParam.keyValues success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            success(respose[@"data"]);
        } else {
            [MBProgressHUD showError:@"获取失败"];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)buyGoldWithSJBuyGoldParam:(SJBuyGoldParam *)buyGoldParam
                          success:(void (^)(NSDictionary *dict))success
                          failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/pay/charge",HOST];
    
    [SJhttptool POST:urlStr paramers:buyGoldParam.keyValues success:^(id respose) {
        success (respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)openVideoWithDict:(NSDictionary *)dict
                  success:(void (^)(NSDictionary *dict))success
                  failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/openvideo",HOST];
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            success(respose[@"data"]);
        } else {
            [MBProgressHUD showError:@"获取失败"];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)requestVideoLiveAccessTokensuccess:(void (^)(NSDictionary *dict))success
                                   failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/accesstoken",HOST];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//请求个人博文
- (void)requestPersonalArticleListWithPageindex:(NSString *)pageindex
                                    andPagesize:(NSString *)pagesize
                                      anduserid:(NSString *)userid
                               withSuccessBlock:(void (^)(id dict))successBlock
                                   andFailBlock:(void (^)(NSError *error))failBlock{
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbyteacher",HOST];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    NSDictionary *parameters =[NSDictionary dictionaryWithObjectsAndKeys:userid,@"userid",pageindex, @"pageindex",pagesize,@"pagesize", nil];
    
    [SJhttptool GET:urlStr paramers:parameters success:^(id respose) {
        if ([respose[@"states"] isEqual:@"1"]) {
            successBlock(respose[@"data"]);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        failBlock(error);
    }];
}

//混合支付请求接口
-(void)mixPaywithSJMixPayParam:(SJMixPayParam *)MixPayParam success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/pay/paybank",HOST];//后台提供的接口
    
    [SJhttptool POST:urlStr paramers:MixPayParam.keyValues success:^(id respose) {
        success (respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)requestUserReferenceDetailWithUserid:(NSString *)user_id
                              andReferenceid:(NSString *)referenceid
                                     success:(void (^)(NSDictionary *dict))success
                                     failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/find?userid=%@&referenceid=%@",HOST,user_id,referenceid];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    SJLog(@"%@",urlStr);
    
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            success(respose[@"data"]);
        } else {
            [MBProgressHUD showError:@"获取失败"];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)modifyReferencePriceWithDict:(NSDictionary *)dict
                             success:(void (^)(NSDictionary *dict))success
                             failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/updateprice",HOST];
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)modifyReferenceServiceDateWith:(NSDictionary *)dict
                               success:(void (^)(NSDictionary *dict))success
                               failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/updateendtime",HOST];
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)stopSellReferenceWithDict:(NSDictionary *)dict
                          success:(void (^)(NSDictionary *dict))success
                          failure:(void (^)(NSError *error))failure
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/stoppay",HOST];
    
    [SJhttptool POST:urlStr paramers:dict success:^(id respose) {
        success(respose);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)GetvideodetailWithDict:(NSDictionary *)dict
                       success:(void (^)(NSDictionary *dict))success
                       failure:(void (^)(NSError *error))failure{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/detail",HOST];
    
    [SJhttptool GET:urlStr paramers:dict success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSString *jsonstr = respose[@"data"];
            //SJLog(@"%@",jsonstr);
            
            NSData *data =[jsonstr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *tmpDict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            success(tmpDict);
        } else {
            [MBProgressHUD showError:@"获取失败"];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)GetQuestionAndAnswerWithDict:(NSDictionary *)dict
                             success:(void (^)(NSDictionary *dict))success
                             failure:(void (^)(NSError *error))failure{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/question/index",HOST];
    
    [SJhttptool GET:urlStr paramers:dict success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            success (respose);
        } else {
            [MBProgressHUD showError:@"获取失败"];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end

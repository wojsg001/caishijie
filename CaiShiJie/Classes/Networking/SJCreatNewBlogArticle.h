//
//  SJCreatNewBlogArticle.h
//  CaiShiJie
//
//  Created by user on 16/4/5.
//  Copyright © 2018年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJCreatNewBlogArticle : NSObject

/*
token：秘钥
userid ：登录用户
time：生成秘钥时间
title :标题
content ：内容
state ：发布方式【0：发布，1：保存】
type :文章类型
pms  ：观看权限【0：公开，1：私密】
lebel ：标签
articleId ：文章id【可以不填，修改的时候填写】
 */

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *pms;
@property (nonatomic, copy) NSString *lebel;
@property (nonatomic, copy) NSString *articleId;

@end

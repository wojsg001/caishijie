//
//  SJParser.h
//  CaiShiJie
//
//  Created by user on 16/7/12.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJParser : NSObject

/**
 *  处理字符串中字体颜色
 *
 *  @param string 内容
 *
 *  @return   所有的需要改变颜色的字体
 */
+ (NSArray *)keywordRangesOfFontColorInString:(NSString *)string;
/**
 *  处理字符串中的表情格式
 *
 *  @param string 内容
 *
 *  @return   表情的range以及去除表情之后的字符串
 */
+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)string;
/**
 *  处理字符串中的网址
 *
 *  @param string 内容
 *
 *  @return 网址替换以及网址替换后的字符串
 */
+ (NSArray *)keywordRangesOfURLInString:(NSString *)string;
/**
 *  处理字符串中股票代码
 *
 *  @param string 内容
 *
 *  @return   所有的股票代码字符串
 */
+ (NSArray *)keywordRangesOfStockColorInString:(NSString *)string;

/**
 处理字符串

 @param string 原字符串

 @return 处理后字符串
 */
+ (NSString *)getHandleString:(NSString *)string;

/**
 替换字符串中的Html标签

 @param str 原字符串

 @return 替换后的字符串
 */
+ (NSString *)replaceAllHtmlLabel:(NSString *)str;

@end

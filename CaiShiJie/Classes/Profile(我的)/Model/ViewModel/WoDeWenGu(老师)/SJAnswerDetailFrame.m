//
//  SJAnswerDetailFrame.m
//  CaiShiJie
//
//  Created by user on 18/7/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnswerDetailFrame.h"
#import "SJAnswerdetailModel.h"
#import "TYTextContainer.h"
#import "SJTextContainerParser.h"

@implementation SJAnswerDetailFrame

- (void)setAnswerModel:(SJAnswerdetailModel *)answerModel {
    
    _answerModel = answerModel;
    
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW=40;
    CGFloat iconH=40;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 10;
    CGSize nameSize = [_answerModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGSize timeSize = [_answerModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _timeF = (CGRect){{timeX, timeY}, timeSize};
    
    // 荣誉
    CGFloat honorX = nameX;
    CGFloat honorY = CGRectGetMaxY(_nameF) + 4;
    CGSize honorSize = [_answerModel.level sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _honorF = (CGRect){{honorX, honorY}, honorSize};
    
    // 回答
    CGFloat answerX = 10;
    CGFloat answerY = CGRectGetMaxY(_honorF) + 10;
    TYTextContainer *contentTextContainer = [SJTextContainerParser getTextContainerWithContent:answerModel.content];
    _contentTextContainer = [contentTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    _answerF = (CGRect){{answerX, answerY}, {SJScreenW - 20, _contentTextContainer.textHeight}};
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_answerF) + 10;
}

@end

//
//  SJWeiHuiDaFrame.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJWeiHuiDaFrame.h"
#import "SJWeiHuiDaModel.h"
#import "SJWeiHuiDaQuestion.h"
#import "TYTextContainer.h"
#import "SJTextContainerParser.h"

@implementation SJWeiHuiDaFrame

- (void)setQuestionModel:(SJWeiHuiDaModel *)questionModel
{
    _questionModel = questionModel;
    
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW = 28;
    CGFloat iconH = 25;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 16;
    CGSize nameSize = [_questionModel.WeiHuiDaQuestionModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGSize timeSize = [_questionModel.WeiHuiDaQuestionModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _timeF = (CGRect){{timeX, timeY}, timeSize};
    
    // 问题
    CGFloat questionX = 10;
    CGFloat questionY = CGRectGetMaxY(_nameF) + 16;
    TYTextContainer *contentTextContainer = [SJTextContainerParser getTextContainerWithContent:_questionModel.WeiHuiDaQuestionModel.content];
    _contentTextContainer = [contentTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    _questionF = (CGRect){{questionX, questionY}, {SJScreenW - 20, _contentTextContainer.textHeight}};
    
    //线条
    CGFloat lineX = 10;
    CGFloat lineY = CGRectGetMaxY(_questionF) + 10;
    _lineViewF = CGRectMake(lineX, lineY, SJScreenW - 10, 0.5f);
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_lineViewF);
}


@end

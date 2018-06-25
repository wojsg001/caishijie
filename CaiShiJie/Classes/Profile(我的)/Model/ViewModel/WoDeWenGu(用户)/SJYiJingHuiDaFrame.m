//
//  SJYiJingHuiDaFrame.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJYiJingHuiDaFrame.h"
#import "SJYiJingHuiDaModel.h"
#import "SJYiJingHuiDaQuestion.h"
#import "SJYiJingHuiDaAnswer.h"
#import "TYTextContainer.h"
#import "SJTextContainerParser.h"

@implementation SJYiJingHuiDaFrame

- (void)setYiJingHuiDaModel:(SJYiJingHuiDaModel *)YiJingHuiDaModel
{
    _YiJingHuiDaModel = YiJingHuiDaModel;
    
    TYTextContainer *contentTextContainer = [SJTextContainerParser getTextContainerWithContent:_YiJingHuiDaModel.YiJingHuiDaQuestionModel.content];
    TYTextContainer *answerTextContainer = [SJTextContainerParser getTextContainerWithContent:_YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.content];
    
    _contentTextContainer = [contentTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    _answerTextContainer = [answerTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW=40;
    CGFloat iconH=40;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 10;
    CGSize nameSize = [_YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGSize timeSize = [_YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _timeF = (CGRect){{timeX, timeY}, timeSize};
    
    // 水平
    CGFloat levelX = nameX;
    CGFloat levelY = CGRectGetMaxY(_nameF) + 4;
    CGSize levelSize = [_YiJingHuiDaModel.YiJingHuiDaQuestionModel.YiJingHuiDaAnswerModel.honor sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _levelF = (CGRect){{levelX, levelY}, levelSize};
    
    // 回答
    CGFloat answerX = 10;
    CGFloat answerY = CGRectGetMaxY(_levelF) + 10;
    _answerF = (CGRect){{answerX, answerY}, {SJScreenW - 20, _answerTextContainer.textHeight}};
    
    // 线条一
    CGFloat line1X = 10;
    CGFloat line1Y = CGRectGetMaxY(_answerF) + 10;
    CGFloat line1W = SJScreenW - 10;
    CGFloat line1H = 0.5f;
    _line1ViewF = CGRectMake(line1X, line1Y, line1W, line1H);
    
    // 问题
    CGFloat questionX = 10;
    CGFloat questionY = CGRectGetMaxY(_line1ViewF) + 10;
    _questionF = (CGRect){{questionX, questionY}, {SJScreenW - 20, _contentTextContainer.textHeight}};
    
    // 回答人数
    CGFloat countY = CGRectGetMaxY(_questionF) + 5;
    CGSize countSize = [_YiJingHuiDaModel.answer_count sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat countX = SJScreenW - countSize.width - 10;
    _countF = (CGRect){{countX, countY}, countSize};
    
    // 底部View
    CGFloat bottomViewY = CGRectGetMaxY(_countF) + 10;
    CGFloat bottomViewX = 0;
    CGFloat bottomViewW = SJScreenW;
    CGFloat bottomViewH = 5;
    _bottomViewF = CGRectMake(bottomViewX, bottomViewY, bottomViewW, bottomViewH);
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_bottomViewF);
}


@end

//
//  SJAnswerFrame.m
//  CaiShiJie
//
//  Created by user on 16/1/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAnswerFrame.h"
#import "SJAnswerModel.h"
#import "TYTextContainer.h"
#import "SJTextContainerParser.h"

@implementation SJAnswerFrame

- (void)setAnswerModel:(SJAnswerModel *)answerModel
{
    _answerModel = answerModel;
    
    TYTextContainer *contentTextContainer = [SJTextContainerParser getTextContainerWithContent:answerModel.content];
    TYTextContainer *answerTextContainer = [SJTextContainerParser getTextContainerWithContent:answerModel.answer];
    
    _contentTextContainer = [contentTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    _answerTextContainer = [answerTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW=30;
    CGFloat iconH=30;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 10;
    CGSize nameSize = [_answerModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGSize timeSize = [_answerModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _timeF = (CGRect){{timeX, timeY}, timeSize};
    
    // 回答人数
    CGFloat countX = nameX;
    CGFloat countY = CGRectGetMaxY(_nameF) + 4;
    CGSize countSize = [_answerModel.answer_count
                        sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _countF = (CGRect){{countX, countY}, countSize};
    
    // 内容
    CGFloat contentX = 10;
    CGFloat contentY = CGRectGetMaxY(_countF) + 10;
    _contentF = (CGRect){{contentX, contentY}, {SJScreenW - 20, _contentTextContainer.textHeight}};
    
    // 线条一
    CGFloat line1X = 10;
    CGFloat line1Y = CGRectGetMaxY(_contentF) + 10;
    CGFloat line1W = SJScreenW - 10;
    CGFloat line1H = 0.5f;
    _line1ViewF = CGRectMake(line1X, line1Y, line1W, line1H);
    
    // 回答
    CGFloat answerX = 10;
    CGFloat answerY = CGRectGetMaxY(_line1ViewF) + 10;
    _answerF = (CGRect){{answerX, answerY}, {SJScreenW - 20, _answerTextContainer.textHeight}};
    
    CGFloat bottomViewY = CGRectGetMaxY(_answerF) + 10;
    // 底部View
    CGFloat bottomViewX = 0;
    CGFloat bottomViewW = SJScreenW;
    CGFloat bottomViewH = 5;
    _bottomViewF = CGRectMake(bottomViewX, bottomViewY, bottomViewW, bottomViewH);
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_bottomViewF);
}

@end

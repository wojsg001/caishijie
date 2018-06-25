//
//  SJQuestionFrame.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJQuestionFrame.h"
#import "SJQuestionModel.h"
#import "TYTextContainer.h"
#import "SJTextContainerParser.h"

@implementation SJQuestionFrame

- (void)setQuestionModel:(SJQuestionModel *)questionModel
{
    _questionModel = questionModel;
    
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW=30;
    CGFloat iconH=30;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 10;
    CGSize nameSize = [_questionModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGSize timeSize = [_questionModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _timeF = (CGRect){{timeX, timeY}, timeSize};
    
    // 内容
    CGFloat contentX = nameX;
    CGFloat contentY = CGRectGetMaxY(_nameF) + 10;
    CGFloat contentW = SJScreenW - nameX - 10;
    TYTextContainer *contentTextContainer = [SJTextContainerParser getTextContainerWithContent:questionModel.content];
    _contentTextContainer = [contentTextContainer createTextContainerWithTextWidth:contentW];
    _contentF = (CGRect){{contentX, contentY}, {contentW, _contentTextContainer.textHeight}};
    
    // 回答按钮
    CGFloat answerBtnY = CGRectGetMaxY(_contentF) + 6;
    CGFloat answerBtnW=50;
    CGFloat answerBtnH=25;
    CGFloat answerBtnX = SJScreenW - answerBtnW - 10;
    _answerBtnF = CGRectMake(answerBtnX, answerBtnY, answerBtnW, answerBtnH);
    
    // 底部View
    CGFloat bottomViewX = 0;
    CGFloat bottomViewY = CGRectGetMaxY(_answerBtnF) + 6;
    CGFloat bottomViewW = SJScreenW;
    CGFloat bottomViewH = 5;
    _bottomViewF = CGRectMake(bottomViewX, bottomViewY, bottomViewW, bottomViewH);
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_bottomViewF);
}

@end

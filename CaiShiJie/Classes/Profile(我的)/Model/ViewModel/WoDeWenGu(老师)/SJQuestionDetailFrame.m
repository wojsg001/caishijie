//
//  SJQuestionDetailFrame.m
//  CaiShiJie
//
//  Created by user on 18/7/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJQuestionDetailFrame.h"
#import "SJDetailModel.h"
#import "TYTextContainer.h"
#import "SJTextContainerParser.h"

@implementation SJQuestionDetailFrame

- (void)setQuestionDetailModel:(SJDetailModel *)questionDetailModel
{
    _questionDetailModel = questionDetailModel;
    
    // 头像
    CGFloat iconX = 10;
    CGFloat iconY = 10;
    CGFloat iconW = 30;
    CGFloat iconH = 30;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = 10;
    CGSize nameSize = [_questionDetailModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = 10;
    CGFloat timeX = CGRectGetMaxX(_nameF);
    CGFloat timeW = SJScreenW - timeX - 10;
    CGSize timeSize = [_questionDetailModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _timeF = (CGRect){{timeX, timeY}, {timeW, timeSize.height}};
    
    // 回答人数
    CGFloat countX = nameX;
    CGFloat countY = CGRectGetMaxY(_nameF) + 4;
    CGSize countSize = [_questionDetailModel.answer_count sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _countF = (CGRect){{countX, countY}, countSize};
    
    // 内容
    CGFloat contentX = 10;
    CGFloat contentY = CGRectGetMaxY(_countF) + 10;
    TYTextContainer *contentTextContainer = [SJTextContainerParser getTextContainerWithContent:questionDetailModel.content];
    _contentTextContainer = [contentTextContainer createTextContainerWithTextWidth:SJScreenW - 20];
    _contentF = (CGRect){{contentX, contentY}, {SJScreenW - 20, _contentTextContainer.textHeight}};
    
    // 计算cell的高度
    _cellH = CGRectGetMaxY(_contentF) + 10;
}

@end

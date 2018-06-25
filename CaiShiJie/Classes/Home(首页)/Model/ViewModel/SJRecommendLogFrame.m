//
//  SJRecommendLogFrame.m
//  CaiShiJie
//
//  Created by user on 18/2/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRecommendLogFrame.h"
#import "SJRecommendLog.h"

@implementation SJRecommendLogFrame

- (void)setLogModel:(SJRecommendLog *)logModel
{
    _logModel = logModel;
    
    // 底部线条
    CGFloat bottomViewX = 0;
    CGFloat bottomViewY = 0;
    CGFloat bottomViewW = SJScreenW;
    CGFloat bottomViewH = 5;
    _bottomViewF = CGRectMake(bottomViewX, bottomViewY, bottomViewW, bottomViewH);
    
    // 头像
    CGFloat head_imgX = 10;
    CGFloat head_imgY = CGRectGetMaxY(_bottomViewF) + 10;
    CGFloat head_imgW = 39;
    CGFloat head_imgH = 39;
    _head_imgF = CGRectMake(head_imgX, head_imgY, head_imgW, head_imgH);
    
    // 昵称
    CGFloat nameX = CGRectGetMaxX(_head_imgF) + 10;
    CGFloat nameY = head_imgY;
    CGSize nameSize = [_logModel.nickname sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _nicknameF = (CGRect){{nameX, nameY}, nameSize};
    
    // 时间
    CGFloat timeY = head_imgY;
    CGSize timeSize = [_logModel.created_at sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat timeX = SJScreenW - timeSize.width - 10;
    _created_atF = (CGRect){{timeX, timeY}, {SJScreenW/2, timeSize.height}};
    
    // 荣誉
    CGFloat honorX = nameX;
    CGFloat honorY = CGRectGetMaxY(_nicknameF) + 10;
    CGSize honorSize = [_logModel.honor sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    _honorF = (CGRect){{honorX, honorY}, honorSize};
    
    // 标题
    CGFloat titleX = head_imgX;
    CGFloat titleY = CGRectGetMaxY(_honorF) + 10;
    CGSize titleSize = [_logModel.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _titleF = (CGRect){{titleX, titleY}, {SJScreenW - 20, titleSize.height}};
    
    // 简介
    CGFloat summaryX = head_imgX;
    CGFloat summaryY = CGRectGetMaxY(_titleF) + 10;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_logModel.summary];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    // 设置行间距
    [paragraphStyle setLineSpacing:10];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:14]
                             range:NSMakeRange(0, attributedString.length)];
    CGSize summarySize = [attributedString boundingRectWithSize:CGSizeMake(SJScreenW - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _summaryF = (CGRect){{summaryX, summaryY}, summarySize};
    
    // 点击量
    CGFloat clicksY = CGRectGetMaxY(_summaryF) + 10;
    CGSize clicksSize = [_logModel.clicks sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    CGFloat clicksX = SJScreenW - clicksSize.width - 10;
    _clicksF = (CGRect){{clicksX, clicksY}, clicksSize};
    
    // 点击量图片
    CGFloat clicks_imgW = 15;
    CGFloat clicks_imgH = 8;
    CGFloat clicks_imgX = clicksX - clicks_imgW - 4;
    CGFloat clicks_imgY = clicksY + 3;
    _clicks_imgF = CGRectMake(clicks_imgX, clicks_imgY, clicks_imgW, clicks_imgH);
    
    // cell的高度
    _cellH = CGRectGetMaxY(_clicksF) + 10;
}

@end

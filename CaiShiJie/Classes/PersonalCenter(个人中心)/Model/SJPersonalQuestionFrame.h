//
//  SJPersonalQuestionFrame.h
//  CaiShiJie
//
//  Created by user on 16/10/9.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJPersonalQuestionModel,TYTextContainer;
@interface SJPersonalQuestionFrame : NSObject

@property (strong, nonatomic) TYTextContainer *questionTextContainer;
@property (strong, nonatomic) NSArray *questionEmotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *questionFontArray;//字体数组
@property (strong, nonatomic) NSArray *questionUrlArray;//网址数组
@property (strong, nonatomic) NSArray *questionStockArray;//股票数组

@property (strong, nonatomic) TYTextContainer *answerTextContainer;
@property (strong, nonatomic) NSArray *answerEmotionArray;//表情和图片数组
@property (strong, nonatomic) NSArray *answerFontArray;//字体数组
@property (strong, nonatomic) NSArray *answerUrlArray;//网址数组
@property (strong, nonatomic) NSArray *answerStockArray;//股票数组

@property (nonatomic, assign) CGRect topViewFrame;
@property (nonatomic, assign) CGRect iconFrame;
@property (nonatomic, assign) CGRect questionFrame;
@property (nonatomic, assign) CGRect answerFrame;
@property (nonatomic, assign) CGRect lineFrame;
@property (nonatomic, assign) CGRect headImageFrame;
@property (nonatomic, assign) CGRect nicknameFrame;
@property (nonatomic, assign) CGRect honourFrame;
@property (nonatomic, assign) CGRect timeFrame;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat questionContentHeight;
@property (nonatomic, assign) CGFloat answerContentHeight;
@property (nonatomic, strong) SJPersonalQuestionModel *model;

@end

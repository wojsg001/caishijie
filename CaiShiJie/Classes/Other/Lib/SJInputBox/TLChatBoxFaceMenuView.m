//
//  TLChatBoxFaceMenuView.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/10/19.
//  Copyright © 2015年 lbk. All rights reserved.
//

#import "TLChatBoxFaceMenuView.h"
#import "macros.h"
#import "UIView+TL.h"

@interface TLChatBoxFaceMenuView ()

@property (nonatomic, strong) NSMutableArray *faceMenuViewArray;

@end

@implementation TLChatBoxFaceMenuView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

#pragma mark - Public Methods
- (void) setFaceGroupArray:(NSMutableArray *)faceGroupArray
{
    _faceGroupArray = faceGroupArray;
    float w = self.frameHeight * 1.25;
    
    float x = 0;
    int i = 0;
    for (TLFaceGroup *group in faceGroupArray) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, w, self.frameHeight)];
        [button.imageView setContentMode:UIViewContentModeCenter];
        [button setImage:[UIImage imageNamed:group.groupImageName] forState:UIControlStateNormal];
        [button setTag:i ++];
        [button addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        [self.faceMenuViewArray addObject:button];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(button.originX + button.frameWidth, 6, 0.5, self.frameHeight - 12)];
        [line setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];

        x += button.frameWidth + 0.5;
    }
    [self buttonDown:[self.faceMenuViewArray firstObject]];
}

#pragma mark - Event Response
- (void) buttonDown:(UIButton *)sender
{
    for (UIButton *button in self.faceMenuViewArray) {
        [button setBackgroundColor:[UIColor whiteColor]];
    }
    [sender setBackgroundColor:DEFAULT_CHATBOX_COLOR];
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxFaceMenuView:didSelectedFaceMenuIndex:)]) {
        [_delegate chatBoxFaceMenuView:self didSelectedFaceMenuIndex:sender.tag];
    }
}

#pragma mark - Getter
- (NSMutableArray *) faceMenuViewArray
{
    if (_faceMenuViewArray == nil) {
        _faceMenuViewArray = [[NSMutableArray alloc] init];
    }
    return _faceMenuViewArray;
}

@end

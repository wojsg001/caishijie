//
//  TLChatBox.m
//  iOSAppTemplate
//
//  Created by libokun on 15/10/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLChatBox.h"
#import "macros.h"
#import "UIView+TL.h"
#import "UIImage+TL.h"

#define     CHATBOX_BUTTON_WIDTH        37
#define     HEIGHT_TEXTVIEW             HEIGHT_TABBAR * 0.74
#define     MAX_TEXTVIEW_HEIGHT         104


@interface TLChatBox () <UITextViewDelegate>

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation TLChatBox

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _curHeight = frame.size.height;
        [self setBackgroundColor:DEFAULT_CHATBOX_COLOR];
        [self addSubview:self.topLine];
        [self addSubview:self.textView];
        [self addSubview:self.faceButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.sendButton];
        self.status = TLChatBoxStatusNothing;
    }
    return self;
}

#pragma mark - 处理属性改变事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 判断下textView有木有内容
    if (_textView.text.length)
    { // 有内容
        _textView.hidePlaceHolder = YES;
    }
    else
    {
        _textView.hidePlaceHolder = NO;
    }
}

- (void)textChange
{
    // 判断下textView有木有内容
    if (_textView.text.length)
    { // 有内容
        _textView.hidePlaceHolder = YES;
    }
    else
    {
        _textView.hidePlaceHolder = NO;
    }
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.topLine setFrameWidth:self.frameWidth];
    
    float y = self.frameHeight - self.moreButton.frameHeight - (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2;
    if (self.moreButton.originY != y) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.moreButton setOriginY:y];
            [self.faceButton setOriginY:self.moreButton.originY];
            [self.sendButton setOriginY:self.moreButton.originY];
        }];
    }
}

#pragma Public Methods
- (BOOL) resignFirstResponder
{
    [self.textView resignFirstResponder];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_n"] forState:UIControlStateNormal];
    return [super resignFirstResponder];
}

- (void) addEmojiFace:(TLFace *)face
{
    [self.textView setText:[self.textView.text stringByAppendingString:face.faceName]];
    if (MAX_TEXTVIEW_HEIGHT < self.textView.contentSize.height) {
        float y = self.textView.contentSize.height - self.textView.frameHeight;
        y = y < 0 ? 0 : y;
        [self.textView scrollRectToVisible:CGRectMake(0, y, self.textView.frameWidth, self.textView.frameHeight) animated:YES];
    }
    [self textViewDidChange:self.textView];
}

- (void) sendCurrentMessage
{
    if (self.textView.text.length > 0) {     // send Text
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:sendTextMessage:)]) {
            [_delegate chatBox:self sendTextMessage:self.textView.text];
        }
    }
    
    [self.textView setText:@""];
    [self textViewDidChange:self.textView];
}

- (void) deleteButtonDown
{
    [self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""];
    [self textViewDidChange:self.textView];
}

#pragma mark - UITextViewDelegate
- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_h"] forState:UIControlStateNormal];
    
    TLChatBoxStatus lastStatus = self.status;
    self.status = TLChatBoxStatusShowKeyboard;
    if (lastStatus == TLChatBoxStatusShowFace) {
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    }
    else if (lastStatus == TLChatBoxStatusShowMore) {
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    CGFloat height = [textView sizeThatFits:CGSizeMake(self.textView.frameWidth, MAXFLOAT)].height;
    height = height > HEIGHT_TEXTVIEW ? height : HEIGHT_TEXTVIEW;
    height = height < MAX_TEXTVIEW_HEIGHT ? height : textView.frameHeight;
    _curHeight = height + HEIGHT_TABBAR - HEIGHT_TEXTVIEW;
    
    if (_curHeight != self.frameHeight) {
        [UIView animateWithDuration:0.05 animations:^{
            [self setFrameHeight:_curHeight];
            if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeChatBoxHeight:)]) {

                [_delegate chatBox:self changeChatBoxHeight:_curHeight];
            }
        }];
    }
    if (height != textView.frameHeight) {
        [UIView animateWithDuration:0.05 animations:^{
            [textView setFrameHeight:height];
        }];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length > 0 && [text isEqualToString:@""]) {       // delete
        if ([textView.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [textView.text characterAtIndex:location];
                if (c == '[') {
                    textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    return NO;
                }
                else if (c == ']') {
                    return YES;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - Event Response
- (void) sendButtonDown:(UIButton *)sender
{
    [self sendCurrentMessage];
}

- (void) faceButtonDown:(UIButton *)sender
{
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_h"] forState:UIControlStateNormal];
    
    TLChatBoxStatus lastStatus = self.status;
    if (lastStatus == TLChatBoxStatusShowFace) {       // 正在显示表情，改为现实键盘状态
        self.status = TLChatBoxStatusShowKeyboard;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
    else {
        self.status = TLChatBoxStatusShowFace;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == TLChatBoxStatusShowMore) {
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        }
        else if (lastStatus == TLChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
}

- (void) moreButtonDown:(UIButton *)sender
{
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_h"] forState:UIControlStateNormal];
    
    TLChatBoxStatus lastStatus = self.status;
    if (lastStatus == TLChatBoxStatusShowMore) {
        self.status = TLChatBoxStatusShowKeyboard;
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
    else {
        self.status = TLChatBoxStatusShowMore;
        [_moreButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == TLChatBoxStatusShowFace) {
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        }
        else if (lastStatus == TLChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
}

#pragma mark - Getter
- (UIView *) topLine
{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
        [_topLine setBackgroundColor:[UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1.0]];
    }
    return _topLine;
}

- (UIButton *) sendButton
{
    if (_sendButton == nil) {
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH_SCREEN - 60, (HEIGHT_TABBAR - 35) / 2, 50, 35)];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_n"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (SJTextView *) textView
{
    if (_textView == nil) {
        _textView = [[SJTextView alloc] initWithFrame:CGRectMake(self.faceButton.originX + self.faceButton.frameWidth + 4, self.frameHeight * 0.13, self.sendButton.originX - self.faceButton.originX - self.faceButton.frameWidth - 8, HEIGHT_TEXTVIEW)];
        [_textView setFont:[UIFont systemFontOfSize:16.0f]];
        [_textView.layer setMasksToBounds:YES];
        [_textView.layer setCornerRadius:4.0f];
        [_textView.layer setBorderWidth:0.5f];
        [_textView.layer setBorderColor:self.topLine.backgroundColor.CGColor];
        [_textView setScrollsToTop:NO];
        [_textView setReturnKeyType:UIReturnKeyDefault];
        [_textView setDelegate:self];
        _textView.placeHolder = @"开始互动吧...";
        _textView.placeHolderLabelY = 9;
        _textView.placeHolderLabelX = 8;
        
        // 监听文本框内容改变
        [_textView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        // 监听文本框的输入
        /**
         *  Observer:谁需要监听通知
         *  name：监听的通知的名称
         *  object：监听谁发送的通知，nil:表示谁发送我都监听
         *
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
    }
    return _textView;
}

- (UIButton *) faceButton
{
    if (_faceButton == nil) {
        _faceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.moreButton.originX + CHATBOX_BUTTON_WIDTH, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIButton *) moreButton
{
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (void) setMoreButtonHidden:(BOOL)isHidden {
    if (isHidden) {
        self.moreButton.hidden = isHidden;
        self.faceButton.frame = CGRectMake(0, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH);
        self.textView.frame = CGRectMake(self.faceButton.originX + self.faceButton.frameWidth + 4, self.frameHeight * 0.13, self.sendButton.originX - self.faceButton.originX - self.faceButton.frameWidth - 8, HEIGHT_TEXTVIEW);
        self.sendButton.frame = CGRectMake(WIDTH_SCREEN - 60, (HEIGHT_TABBAR - 35) / 2, 50, 35);
    }
}

- (void)updateSubviewsFrame {
    self.faceButton.frame = CGRectMake(0, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH);
    self.sendButton.frame = CGRectMake(HEIGHT_SCREEN - 60, (HEIGHT_TABBAR - 35) / 2, 50, 35);
    self.textView.frame = CGRectMake(self.faceButton.originX + self.faceButton.frameWidth + 4, self.frameHeight * 0.13, self.sendButton.originX - self.faceButton.originX - self.faceButton.frameWidth - 8, HEIGHT_TEXTVIEW);
}

- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

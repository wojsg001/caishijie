//
//  SJSpeechRecognizerView.m
//  CaiShiJie
//
//  Created by user on 16/3/15.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJSpeechRecognizerView.h"

@interface SJSpeechRecognizerView ()

@property (weak, nonatomic) IBOutlet UIButton *startOrEndBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@end

@implementation SJSpeechRecognizerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.startOrEndBtn.layer.borderWidth = 0.5f;
    self.startOrEndBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.startOrEndBtn.layer.cornerRadius = 5;
    self.startOrEndBtn.layer.masksToBounds = YES;
    self.lineHeight.constant = 0.5f;
}


- (IBAction)startOrEndBtnPressed:(id)sender
{
    self.startOrEndBtn.selected = !self.startOrEndBtn.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(startOrEndSpeechRecognizer:)])
    {
        [self.delegate startOrEndSpeechRecognizer:self.startOrEndBtn.selected];
    }
}

- (void)setUpStartOrEndButtonWithImage:(UIImage *)img
{
    [self.startOrEndBtn setImage:img forState:UIControlStateNormal];
}

@end

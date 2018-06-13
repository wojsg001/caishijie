//
//  SJPopupModifyPriceView.m
//  CaiShiJie
//
//  Created by user on 16/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPopupModifyPriceView.h"
#import "LewPopupViewController.h"
#import "SJMyNeiCan.h"
#import "SJToken.h"
#import "SJNetManager.h"

@interface SJPopupModifyPriceView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *nowPriceTextField;

@end

@implementation SJPopupModifyPriceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        
        _innerView.frame = frame;
        _innerView.layer.cornerRadius = 5;
        _innerView.layer.masksToBounds = YES;
        
        _nowPriceTextField.delegate = self;
        
        _oldPriceTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
        _oldPriceTextField.leftViewMode = UITextFieldViewModeAlways;
        _nowPriceTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
        _nowPriceTextField.leftViewMode = UITextFieldViewModeAlways;
        
        [self addSubview:_innerView];
        
        // 监听键盘的弹出
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    }
    return self;
}

+ (instancetype)defaultPopupView
{
    return [[SJPopupModifyPriceView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW - 30, 270)];
}

- (void)setModel:(SJMyNeiCan *)model {
    _model = model;
    
    self.oldPriceTextField.text = [NSString stringWithFormat:@"¥%@", _model.price];
}

#pragma mark - Notification event
- (void)keyboardFrameChange:(NSNotification *)note
{
    
    CGFloat durtion = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 获取键盘的frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (frame.origin.y == SJScreenH) { // 没有弹出键盘
        if (frame.size.height > (SJScreenH - 270)/2)
        {
            [UIView animateWithDuration:durtion animations:^{
                self.transform =  CGAffineTransformIdentity;
            }];
        }
    } else { // 弹出键盘
        if (frame.size.height > (SJScreenH - 270)/2)
        {
            [UIView animateWithDuration:durtion animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, -(frame.size.height - (SJScreenH - 270)/2));
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

// 点击取消按钮
- (IBAction)dismissViewDropAction:(id)sender
{
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopBottom;
    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

// 点击确定按钮
- (IBAction)ClickOKButton:(id)sender
{
    NSString *text = [self.nowPriceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length == 0) {
        [MBHUDHelper showWarningWithText:@"请输入价格！"];
        return;
    }
    
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"price":text,@"targetid":_model.reference_id};
    
    //SJLog(@"%@",dict);
    // 修改价格
    [[SJNetManager sharedNetManager] modifyReferencePriceWithDict:dic success:^(NSDictionary *dict) {
        [MBHUDHelper showWarningWithText:dict[@"data"]];
        if ([dict[@"states"] isEqualToString:@"1"]) {
            // 如果修改价格成功刷新界面
            if (self.delegate && [self.delegate respondsToSelector:@selector(SJPopupModifyPriceViewRefreshSuperView)]) {
                [self.delegate SJPopupModifyPriceViewRefreshSuperView];
            }
        }
    } failure:^(NSError *error) {
        
    }];
    
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopBottom;
    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nowPriceTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate 代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_nowPriceTextField setBackground:[UIImage imageNamed:@"change_price_imputicon"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_nowPriceTextField setBackground:[UIImage imageNamed:@"neican_price_inputicon"]];
}

@end

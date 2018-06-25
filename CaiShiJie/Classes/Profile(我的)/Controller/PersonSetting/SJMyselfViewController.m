//
//  SJMyselfViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyselfViewController.h"
#import "NSString+SJMD5.h"
#import "SJNetManager.h"
#import "SJhttptool.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+MJ.h"

@interface SJMyselfViewController ()<UITextViewDelegate>

@property (nonatomic,strong)UILabel *lable;

@end

@implementation SJMyselfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupnavigationbar];
    [self setuptextview];
    self.view.backgroundColor = RGB(245, 245, 248);
    
    if (self.str.length) {
        self.textview.text = self.str;
        self.numberlable.text = [NSString stringWithFormat:@"%d",self.textview.text.length];
        _lable.hidden = YES;
    } else {
        _lable.hidden = NO;
    }
}

- (void)setupnavigationbar {
    
    self.navigationItem.title = @"我的简介";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setuptextview {
    _lable = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, SJScreenW, 40)];
    _lable.text = @"请输入您的个人简介...";
    _lable.textColor = RGB(153, 153, 153);
    _lable.font = [UIFont systemFontOfSize:17];
    [self.textview addSubview:_lable];
    self.textview.backgroundColor = RGB(255, 255, 255);
    
    // 默认允许垂直方向拖拽
    self.textview.alwaysBounceVertical = YES;
    // 监听拖拽
    self.textview.delegate = self;
}

#pragma mark - 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 500) {
        [self.view endEditing:YES];
        [MBHUDHelper showWarningWithText:@"你输入的字数已经超过了限制！"];
        textView.text = [textView.text substringToIndex:500];
        self.numberlable.text = [NSString stringWithFormat:@"%d",textView.text.length];
    }
    self.numberlable.text = [NSString stringWithFormat:@"%d",textView.text.length];
}

#pragma mark - 保存信息
- (void)save {
    NSString *url = [NSString stringWithFormat:@"%@/mobile/user/introduction",HOST];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    NSString *content = self.textview.text;
    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",content,@"content",nil];
    [SJhttptool POST:url paramers:paramers success:^(id respose) {
        
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"修改失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"网络错误！"];
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

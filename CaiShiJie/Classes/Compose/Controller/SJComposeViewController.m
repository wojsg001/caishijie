//
//  SJComposeViewController.m
//  CaiShiJie
//
//  Created by user on 18/1/14.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJComposeViewController.h"
#import "SJTextView.h"
#import "SJNetManager.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"

@interface SJComposeViewController ()<UITextViewDelegate>
{
    SJNetManager *netManager;
}
@property (nonatomic, weak) SJTextView *textView;

@end

@implementation SJComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    netManager = [SJNetManager sharedNetManager];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.userid = [d valueForKey:kUserid];
    
    // 设置导航条
    [self setUpNavgationBar];
    // 添加textView
    [self setUpTextView];
}

#pragma mark - 添加textView
- (void)setUpTextView
{
    SJTextView *textView = [[SJTextView alloc] initWithFrame:self.view.bounds];
    _textView = textView;
    // 设置占位符
    textView.placeHolder = @"编写内容吧...";
    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    
    // 默认允许垂直方向拖拽
    textView.alwaysBounceVertical = YES;
    
    // 监听文本框的输入
    /**
     *  Observer:谁需要监听通知
     *  name：监听的通知的名称
     *  object：监听谁发送的通知，nil:表示谁发送我都监听
     *
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
    
    // 监听拖拽
    _textView.delegate = self;
}

#pragma mark - 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)textChange
{
    // 判断下textView有木有内容
    if (_textView.text.length) { // 有内容
        _textView.hidePlaceHolder = YES;
    }else{
        _textView.hidePlaceHolder = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_textView becomeFirstResponder];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setUpNavgationBar
{

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];

    self.navigationItem.rightBarButtonItem = rightItem;

}

// 发送
- (void)compose
{
    
    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    if ([self.type isEqual:@"0"])
    {
        // 提问问题
        if ([self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 1)
        {
            [MBHUDHelper showWarningWithText:@"请输入您的问题!"];
            return;
        }
        
        SJToken *instance = [SJToken sharedToken];
        
        [netManager sendQuestionWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.targetid andContent:self.textView.text];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([self.type isEqual:@"1"])
    {
        // 回答问题
        SJToken *instance = [SJToken sharedToken];
        
        NSString *itemid = self.itemid;
        NSString *content = self.textView.text;
        if ([content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 1) {
            [MBHUDHelper showWarningWithText:@"请输入回答内容!"];
            return;
        }
        
        NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:instance.token,@"token",itemid,@"itemid",content,@"content",instance.userid,@"userid",instance.time,@"time", nil];
        SJLog(@"%@",paramers);
        NSString *url =[NSString stringWithFormat:@"%@/mobile/live/answerquestion",HOST];
        
        [SJhttptool POST:url paramers:paramers success:^(id respose) {
            SJLog(@"%@",respose);
            if ([respose[@"states"] isEqualToString:@"1"]) {
                // 等数据提交成功后返回界面
                if (self.refreshData) {
                    self.refreshData(YES);
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示信息" message:respose[@"data"] delegate:nil cancelButtonTitle:@" 确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            SJLog(@"%@", error);
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
    }
}


@end

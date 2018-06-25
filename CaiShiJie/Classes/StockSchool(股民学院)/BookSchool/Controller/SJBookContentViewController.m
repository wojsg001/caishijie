//
//  SJBookContentViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/20.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJBookContentViewController.h"
#import "Masonry.h"
#import "SJhttptool.h"
#import "SJBeforeAndNextChapterModel.h"
#import "MJExtension.h"

@interface SJBookContentViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIWebView *webView;
// 存放当前章节的前一页和后一页
@property (nonatomic, strong) NSArray *beforeAndNextChapterArr;

@end

@implementation SJBookContentViewController

- (UIWebView *)webView
{
    if (_webView == nil)
    {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(10, 0, SJScreenW - 20, SJScreenH - 80 - 64)];
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格
    [self setUpTableView];
    // 加载webView
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadWebViewWithChapterid:self.chapterid];
    // 获取当前章节上下章节
    [self getCurrentChapterBeforePageAndNextPageWithChapterid:self.chapterid];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"live_up_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [self tableViewFooterView];
}

- (void)loadWebViewWithChapterid:(NSString *)chapterid
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/mobile/book/detail?chapterid=%@&width=%f",HOST,chapterid,SJScreenW - 20];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}
#pragma mark - 得到当前章节的上下章节
- (void)getCurrentChapterBeforePageAndNextPageWithChapterid:(NSString *)chapterid
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/mobile/book/findpage?chapterid=%@",HOST,chapterid];
    SJLog(@"%@",strUrl);
    [SJhttptool GET:strUrl paramers:nil success:^(id respose) {
        SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            self.beforeAndNextChapterArr = [SJBeforeAndNextChapterModel objectArrayWithKeyValuesArray:respose[@"data"]];
        }
        
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - UIWebViewDelegate 代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    self.webView.height = [output doubleValue];
    
    //SJLog(@"%@",output);
    [MBProgressHUD hideHUDForView:self.view];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.webView)
    {
        return self.webView;
    }
    
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.webView)
    {
        return self.webView.height;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableViewFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 80)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    UIButton *beforeBtn = [[UIButton alloc]init];
    [beforeBtn setTitle:@"上一节" forState:UIControlStateNormal];
    [beforeBtn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
    beforeBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [beforeBtn setBackgroundImage:[UIImage imageNamed:@"chapter_btn_h"] forState:UIControlStateNormal];
    [beforeBtn setBackgroundImage:[UIImage imageNamed:@"chapter_btn_n"] forState:UIControlStateHighlighted];
    beforeBtn.layer.borderColor = RGB(227, 227, 227).CGColor;
    beforeBtn.layer.borderWidth = 0.5f;
    beforeBtn.layer.cornerRadius = 2;
    beforeBtn.layer.masksToBounds = YES;
    [beforeBtn addTarget:self action:@selector(beforeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:beforeBtn];
    
    UIButton *nextBtn = [[UIButton alloc]init];
    [nextBtn setTitle:@"下一节" forState:UIControlStateNormal];
    [nextBtn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"chapter_btn_h"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"chapter_btn_n"] forState:UIControlStateHighlighted];
    nextBtn.layer.borderColor = RGB(227, 227, 227).CGColor;
    nextBtn.layer.borderWidth = 0.5f;
    nextBtn.layer.cornerRadius = 2;
    nextBtn.layer.masksToBounds = YES;
    [nextBtn addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:nextBtn];
    

    [beforeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView.mas_top).offset(20);
        make.left.equalTo(footerView.mas_left).offset(22);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(nextBtn);
    }];
    
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView.mas_top).offset(20);
        make.left.equalTo(beforeBtn.mas_right).offset(30);
        make.right.equalTo(footerView.mas_right).offset(-22);
        make.height.mas_equalTo(40);
    }];
    
    return footerView;
}

- (void)beforeButtonClick:(UIButton *)sender
{
    if (!self.beforeAndNextChapterArr.count)
    {
        [MBHUDHelper showWarningWithText:@"没有上一节了"];
        return;
    }
    
    BOOL isHave = NO;
    for (SJBeforeAndNextChapterModel *model in self.beforeAndNextChapterArr)
    {
        if ([model.types isEqualToString:@"2"])
        {
            self.navigationItem.title = model.title;
            self.webView = nil;
            [MBProgressHUD showMessage:@"加载中..." toView:self.view];
            [self loadWebViewWithChapterid:model.chapter_id];
            [self getCurrentChapterBeforePageAndNextPageWithChapterid:model.chapter_id];
            isHave = YES;
            
            break;
        }
    }
    
    if (isHave == NO)
    {
        [MBHUDHelper showWarningWithText:@"没有上一节了"];
    }
}

- (void)nextButtonClick:(UIButton *)sender
{
    if (!self.beforeAndNextChapterArr.count)
    {
        [MBHUDHelper showWarningWithText:@"没有下一节了"];
        return;
    }
    
    BOOL isHave = NO;
    for (SJBeforeAndNextChapterModel *model in self.beforeAndNextChapterArr)
    {
        if ([model.types isEqualToString:@"1"])
        {
            self.navigationItem.title = model.title;
            self.webView = nil;
            [MBProgressHUD showMessage:@"加载中..." toView:self.view];
            [self loadWebViewWithChapterid:model.chapter_id];
            [self getCurrentChapterBeforePageAndNextPageWithChapterid:model.chapter_id];
            isHave = YES;
            
            break;
        }
    }
    
    if (isHave == NO)
    {
        [MBHUDHelper showWarningWithText:@"没有下一节了"];
    }
}

@end

//
//  SJUserReferenceDetailViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/28.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJUserReferenceDetailViewController.h"
#import "SJUserReferenceDetailCell.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJMyNeiCan.h"
#import "MJExtension.h"

@interface SJUserReferenceDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SJUserReferenceDetailCell *userReferenceDetailCell;
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation SJUserReferenceDetailViewController

- (SJUserReferenceDetailCell *)userReferenceDetailCell {
    if (_userReferenceDetailCell == nil) {
        _userReferenceDetailCell = [[NSBundle mainBundle] loadNibNamed:@"SJUserReferenceDetailCell" owner:nil options:nil].lastObject;
        _userReferenceDetailCell.frame = CGRectMake(0, 0, SJScreenW, 105);
    }
    return _userReferenceDetailCell;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(10, 0, SJScreenW - 20, SJScreenH - 105 - 64)];
        
        _webView = web;
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格属性
    [self setUpTableView];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadUserReferenceDetailData];
}

- (void)setUpTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 加载用户内参详细数据
- (void)loadUserReferenceDetailData {
    SJToken *instance = [SJToken sharedToken];
    
    [[SJNetManager sharedNetManager] requestUserReferenceDetailWithUserid:instance.userid andReferenceid:self.referenceid success:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        // SJLog(@"%@",dict);
        self.userReferenceDetailCell.model = [SJMyNeiCan objectWithKeyValues:dict];
        
        NSURL *urlStr = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile/reference/detail?referenceid=%@&userid=%@&pagesize=%@&token=%@&time=%@&width=%f",HOST,self.referenceid,instance.userid,@"5",instance.token,instance.time,SJScreenW - 20]];
        
        // SJLog(@"%@",urlStr);
        NSURLRequest *request = [NSURLRequest requestWithURL:urlStr];
        [self.webView loadRequest:request];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
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
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.userReferenceDetailCell;
    }
    else
    {
        return self.webView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.userReferenceDetailCell.height;
    }
    else
    {
        return self.webView.height;
    }
}

@end

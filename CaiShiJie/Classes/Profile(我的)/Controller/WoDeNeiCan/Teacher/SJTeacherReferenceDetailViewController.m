//
//  SJTeacherReferenceDetailViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJTeacherReferenceDetailViewController.h"
#import "SJTeacherReferenceDetailCell.h"
#import "SJNetManager.h"
#import "NSString+SJMD5.h"
#import "SJMyNeiCan.h"
#import "MJExtension.h"
#import "MJRefresh.h"

#import "LewPopupViewController.h"
#import "SJPopupModifyPriceView.h"
#import "SJPopupModifyServiceDateView.h"
#import "SJCreateNewReferenceViewController.h"
#import "SJAddNewReferenceViewController.h"

@interface SJTeacherReferenceDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,SJTeacherReferenceDetailCellDelegate,SJPopupModifyPriceViewDelegate,SJPopupModifyServiceDateViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SJTeacherReferenceDetailCell *teacherReferenceDetailCell;
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, strong) SJMyNeiCan *infoModel;

@end

@implementation SJTeacherReferenceDetailViewController

- (SJTeacherReferenceDetailCell *)teacherReferenceDetailCell {
    if (_teacherReferenceDetailCell == nil) {
        _teacherReferenceDetailCell = [[NSBundle mainBundle] loadNibNamed:@"SJTeacherReferenceDetailCell" owner:nil options:nil].lastObject;
        _teacherReferenceDetailCell.frame = CGRectMake(0, 0, SJScreenW, 230);
        _teacherReferenceDetailCell.delegate = self;
    }
    return _teacherReferenceDetailCell;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(10, 0, SJScreenW - 20, SJScreenH - 230 - 64)];
        
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
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadTeacherReferenceDetailData)];
    self.tableView.headerRefreshingText = @"正在刷新";

    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_inner_fabu"] style:UIBarButtonItemStylePlain target:self action:@selector(createOneNewReference)];
    
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 开始加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadTeacherReferenceDetailData];
}

#pragma mark - 创建新内参
- (void)createOneNewReference
{
    SJCreateNewReferenceViewController *createNewReferenceVC = [[SJCreateNewReferenceViewController alloc] init];
    createNewReferenceVC.title = @"发表新内参";
    
    [self.navigationController pushViewController:createNewReferenceVC animated:YES];
}

- (void)setUpTableView
{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 加载老师内参详细数据
- (void)loadTeacherReferenceDetailData
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    // md5加密成得到token
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    [[SJNetManager sharedNetManager] requestUserReferenceDetailWithUserid:user_id andReferenceid:self.referenceid success:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        
        //SJLog(@"内参详情%@",dict);
        _infoModel = [SJMyNeiCan objectWithKeyValues:dict];
        self.teacherReferenceDetailCell.model = _infoModel;
        
        NSURL *urlStr = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile/reference/detail?referenceid=%@&userid=%@&pagesize=%@&token=%@&time=%@&width=%f",HOST,self.referenceid,user_id,@"5",md5Auth_key,datestr,SJScreenW - 20]];
        
        // SJLog(@"%@",urlStr);
        NSURLRequest *request = [NSURLRequest requestWithURL:urlStr];
        [self.webView loadRequest:request];
    
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
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
        return self.teacherReferenceDetailCell;
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
        return self.teacherReferenceDetailCell.height;
    }
    else
    {
        return self.webView.height;
    }
}

#pragma mark - SJTeacherReferenceDetailCellDelegate 代理方法
- (void)ClickModifyPriceButton
{
    // 点击修改价格
    SJPopupModifyPriceView *view = [SJPopupModifyPriceView defaultPopupView];
    view.parentVC = self;
    view.model = _infoModel;
    view.delegate = self;
    
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeBottomBottom;
    [self lew_presentPopupView:view animation:animation dismissed:^{
        NSLog(@"动画结束");
    }];
}

- (void)ClickModifyServiceDateButton
{
    // 点击修改服务期
    SJPopupModifyServiceDateView *view = [SJPopupModifyServiceDateView defaultPopupView];
    view.parentVC = self;
    view.model = _infoModel;
    view.delegate = self;
    
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeBottomBottom;
    [self lew_presentPopupView:view animation:animation dismissed:^{
        NSLog(@"动画结束");
    }];
}
// 停止销售成功后刷新界面
- (void)SJTeacherReferenceDetailCellRefreshSuperView
{
    [self.tableView headerBeginRefreshing];
}

// 创建新内参
- (void)SJTeacherReferenceDetailCellCreateNewReference
{
    [self createOneNewReference];
}
// 追加内参
- (void)SJTeacherReferenceDetailAddReference
{
    SJAddNewReferenceViewController *addNewReferenceVC = [[SJAddNewReferenceViewController alloc] init];
    addNewReferenceVC.title = @"内参详情";
    addNewReferenceVC.model = _infoModel;
    
    [self.navigationController pushViewController:addNewReferenceVC animated:YES];
}

#pragma mark - SJPopupModifyPriceViewDelegate 代理方法
- (void)SJPopupModifyPriceViewRefreshSuperView
{
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadTeacherReferenceDetailData];
}

#pragma mark - SJPopupModifyServiceDateViewDelegate 代理方法
- (void)SJPopupModifyServiceDateViewRefreshSuperView
{
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadTeacherReferenceDetailData];
}

@end

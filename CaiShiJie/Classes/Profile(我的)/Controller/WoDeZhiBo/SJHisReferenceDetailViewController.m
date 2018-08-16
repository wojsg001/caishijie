//
//  SJHisReferenceDetailViewController.m
//  CaiShiJie
//
//  Created by user on 18/3/29.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHisReferenceDetailViewController.h"
#import "SJHisReferenceDetailCell.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJMyNeiCan.h"
#import "MJExtension.h"
#import "SJNetManager.h"
#import "SJMixPayParam.h"
#import "SJUserInfo.h"
#import "SJGoldPay.h"
#import "SJNetManager.h"
#import "SJGiftModel.h"
#import "SJLoginViewController.h"
#import "SJNeiCanPayViewController.h"

@interface SJHisReferenceDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate,SJHisReferenceDetailCellDelegate>
{
    SJNetManager *netManager;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SJHisReferenceDetailCell *hisReferenceDetailCell;
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation SJHisReferenceDetailViewController

- (SJHisReferenceDetailCell *)hisReferenceDetailCell {
    if (_hisReferenceDetailCell == nil) {
        _hisReferenceDetailCell = [[NSBundle mainBundle] loadNibNamed:@"SJHisReferenceDetailCell" owner:nil options:nil].lastObject;
        _hisReferenceDetailCell.frame = CGRectMake(0, 0, SJScreenW, 105);
        _hisReferenceDetailCell.delegate = self;
    }
    return _hisReferenceDetailCell;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 加载数据
    [self loadHisReferenceDetailData];
}

- (void)setUpTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 加载用户内参详细数据
- (void)loadHisReferenceDetailData {
    SJToken *instance = [SJToken sharedToken];
    
    [[SJNetManager sharedNetManager] requestUserReferenceDetailWithUserid:instance.userid andReferenceid:self.referenceid success:^(NSDictionary *dict) {
        SJMyNeiCan *model = [SJMyNeiCan objectWithKeyValues:dict];
        self.hisReferenceDetailCell.model = model;
        
        NSURL *urlStr = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile/reference/detail?referenceid=%@&userid=%@&pagesize=%@&token=%@&time=%@&width=%f",HOST,self.referenceid,instance.userid,@"5",instance.token,instance.time,SJScreenW - 20]];
        
        // SJLog(@"%@",urlStr);
        NSURLRequest *request = [NSURLRequest requestWithURL:urlStr];
        [self.webView loadRequest:request];
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

#pragma mark - UIWebViewDelegate 代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    self.webView.height = [output doubleValue];
    //SJLog(@"%@",output);
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.hisReferenceDetailCell;
    } else {
        return self.webView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.hisReferenceDetailCell.height;
    } else {
        return self.webView.height;
    }
}

#pragma mark - SJHisReferenceDetailCellDelegate 代理方法
- (void)didClickPayButtonWith:(SJMyNeiCan *)model {
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
//        SJGiftModel *model = [[SJGiftModel alloc] init];
//        model.gift_id = hisReferenceDetail.reference_id;
//        model.gift_name = @"内参";
//        model.price = hisReferenceDetail.price;
//        [SJPayView showSJPayViewWithGiftModel:model targetid:hisReferenceDetail.user_id itemtype:@"20"];
        SJNeiCanPayViewController *payVC = [[SJNeiCanPayViewController alloc] init];
        payVC.model = model;
        [self.navigationController pushViewController:payVC animated:YES];
    } else {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

@end

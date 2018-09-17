
//
//  SJselfSelectedViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJselfSelectedViewController.h"
#import "SJMySelectedStockModel.h"
#import "SJselfSelectedCell.h"
#import "SJselfSelectedDefaultController.h"
#import "SJEditViewController.h"
#import "SJsearchController.h"
#import "SJhttptool.h"
#import "SJUserInfo.h"
#import "SJStockDetailContentViewController.h"
#import "MJRefresh.h"
#import "SJToken.h"
#import "MJExtension.h"
#import "AFNetworking.h"

@interface SJselfSelectedViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,SJNoWifiViewDelegate>
{
    int page; // 分页
}

@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
//未登录界面
@property (nonatomic, strong) SJselfSelectedDefaultController *defaultvc;
@property (nonatomic, strong) NSMutableArray *attentionList;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJselfSelectedViewController

- (NSMutableArray *)attentionList {
    if (!_attentionList) {
        _attentionList = [NSMutableArray array];
    }
    return _attentionList;
}

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    self.lineViewHeight.constant = 0.5f;
    self.isNetwork = YES;
    
    // 设置搜索框
    [self setUpSearchBar];
    // 设置表格
    [self setUpTableView];
    
    [self.tableview addHeaderWithTarget:self action:@selector(loadData)];
    [self.tableview addFooterWithTarget:self action:@selector(loadMoreData)];
    self.tableview.headerRefreshingText = @"正在刷新...";
    self.tableview.footerRefreshingText = @"正在加载...";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self refreshNetwork];
}

- (void)setUpSearchBar
{
    _searchBar.keyboardType = UIKeyboardAppearanceDefault;
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    _searchBar.barTintColor = RGB(245, 245, 248);
    _searchBar.layer.borderColor = RGB(245, 245, 248).CGColor;
    _searchBar.layer.borderWidth = 1;
    _searchBar.searchBarStyle = UISearchBarStyleDefault;
    _searchBar.barStyle = UIBarStyleDefault;
    UITextField *searchTextField = [[[_searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.layer.borderColor = RGB(227, 227, 227).CGColor
    ;
    searchTextField.layer.borderWidth = 0.5f;
    searchTextField.layer.cornerRadius = 4.0f;
    searchTextField.layer.masksToBounds = YES;
}

- (void)setUpTableView
{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:@"updataselfselected" object:nil];

    UINib *nib =[UINib nibWithNibName:@"SJselfSelectedCell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"cell"];
}

- (void)loadData{
    page = 1;
    NSString *url = [NSString stringWithFormat:@"%@/mobile/stock/getbyuserid", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"pageindex":[NSString stringWithFormat:@"%i",page],@"pagesize":@"10"};
    
    [SJhttptool GET:url paramers:param success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableview headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        //SJLog(@"测试%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJMySelectedStockModel objectArrayWithKeyValuesArray:respose[@"data"][@"attention"]];
            [self.attentionList removeAllObjects];
            [self.dataList removeAllObjects];
            [self.tableview reloadData];
            if (tmpArray.count) {
                self.noDataView.hidden = YES;
                self.tableview.hidden = NO;
                [self.attentionList addObjectsFromArray:tmpArray];
                [self loadSinnaStock:tmpArray];
            } else {
                self.noDataView.hidden = NO;
                self.tableview.hidden = YES;
            }
            
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
            
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableview headerEndRefreshing];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadMoreData{
    
    page = page + 1;
    
    NSString *url = [NSString stringWithFormat:@"%@/mobile/stock/getbyuserid", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"pageindex":[NSString stringWithFormat:@"%i",page],@"pagesize":@"10"};
    
    [SJhttptool GET:url paramers:param success:^(id respose) {

        [self.tableview footerEndRefreshing];
        //SJLog(@"测试%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            
            NSArray *tmpArray = [SJMySelectedStockModel objectArrayWithKeyValuesArray:respose[@"data"][@"attention"]];
            if (tmpArray.count) {
                [self.attentionList removeAllObjects];
                [self.attentionList addObjectsFromArray:tmpArray];
                [self loadSinnaStock:tmpArray];
            }
            
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.tableview footerEndRefreshing];
    }];
}

- (void)loadSinnaStock:(NSArray *)array {
    NSMutableString *stockStr = [NSMutableString string];
    for (SJMySelectedStockModel *model in array) {
        [stockStr appendString:@"s_"];
        [stockStr appendString:model.type];
        [stockStr appendString:model.code];
        [stockStr appendString:@","];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@", stockStr];
    SJLog(@"%@", urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:encode];
        
        NSArray *matches = [self matcheInString:obj regularExpressionWithPattern:@"s_([a-z]{2})([0-9]{6})=\"(\\S{1,})\""];
        for (NSTextCheckingResult *match in matches) {
            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
            
            NSString *tmpStrOne = [obj substringWithRange:match.range];
            NSArray *tmpArrayOne = [tmpStrOne componentsSeparatedByString:@"="];
            
            NSString *tmpStrTwo = tmpArrayOne[1];
            tmpStrTwo = [tmpStrTwo stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *tmpArrayTwo = [tmpStrTwo componentsSeparatedByString:@","];
            tmpDic[@"name"] = tmpArrayTwo[0];
            tmpDic[@"trade"] = tmpArrayTwo[1];
            tmpDic[@"changepercent"] = tmpArrayTwo[3];
            
            NSString *tmpStrThree = tmpArrayOne[0];
            tmpStrThree = [tmpStrThree stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            tmpDic[@"code"] = [tmpStrThree substringWithRange:NSMakeRange(4, 6)];
            tmpDic[@"code2"] = [tmpStrThree substringWithRange:NSMakeRange(2, 8)];
            
            [self.dataList addObject:tmpDic];
            [self.tableview reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:string options:0 range:range];
    return matches;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SJselfSelectedCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    if (self.dataList.count) {
        cell.dict = self.dataList[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = self.dataList[indexPath.row];
    SJStockDetailContentViewController *stockDetailVC =[[SJStockDetailContentViewController alloc] init];
    stockDetailVC.code = dic[@"code"];
    stockDetailVC.name = dic[@"name"];
    stockDetailVC.type = [dic[@"code2"] substringWithRange:NSMakeRange(0, 2)];
    [self.navigationController pushViewController:stockDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    SJsearchController *searchvc =[[SJsearchController alloc] init];
    
    [self.navigationController pushViewController:searchvc animated:YES];
    
    return NO;
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadData];
    } else {
        // 加载数据
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadData];
    }
}

@end

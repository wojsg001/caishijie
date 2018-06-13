//
//  SJRoseController.m
//  CaiShiJie
//
//  Created by user on 16/5/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJRoseController.h"
#import "SJselfSelectedCell.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "SJStockDetailContentViewController.h"

@interface SJRoseController ()<UITableViewDataSource,UITableViewDelegate>
{
    int page; // 分页
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJRoseController

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"涨幅榜";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"SJselfSelectedCell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"cellID"];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadData];
    
    [self.tableview addHeaderWithTarget:self action:@selector(loadData)];
    [self.tableview addFooterWithTarget:self action:@selector(loadMoreData)];
    self.tableview.headerRefreshingText = @"正在刷新";
    self.tableview.footerRefreshingText = @"正在加载";
}

#pragma mark - 加载涨幅榜数据
- (void)loadData{
    page = 1;
    NSString *urlStr = [NSString stringWithFormat:@"http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=%i&num=10&sort=changepercent&asc=0&node=hs_a&symbol=&_s_r_a=sort", page];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableview headerEndRefreshing];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        //
        NSString *searchText = obj;
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"[0-9]{2}:[0-9]{2}:[0-9]{2}\"" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *results = [regex matchesInString:searchText options:0 range:NSMakeRange(0, searchText.length)];
        
        if (results.count) {
            
            NSMutableArray *arrM = [NSMutableArray array];
            for (int i = 0; i < results.count; i++) {
                NSTextCheckingResult *result = results[i];
                NSString *str = [searchText substringWithRange:result.range];
                
                [arrM addObject:str];
            }
            
            for (int i = 0; i < arrM.count; i++) {
                searchText = [searchText stringByReplacingOccurrencesOfString:arrM[i] withString:@"11"];
            }
        }
        
        
        NSString *validString = [searchText stringByReplacingOccurrencesOfString:@"(\\w+)\\s*:([^a-zA-Z0-9_.:-]+)" withString:@"\"$1\":$2" options:NSRegularExpressionSearch range:NSMakeRange(0, [searchText length])];
        
        //SJLog(@"validString%@",validString);
        
        NSString *  validString2 = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])(\\w+)\\s*:" withString:@"$1\"$2\":" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
        
        //SJLog(@"validString%@",validString2);
        
        NSData *data =[validString2 dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arr7 =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        //SJLog(@"arr7%@",arr7);
        
        if (arr7.count) {
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:arr7];
        }
        
        [self.tableview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableview headerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 加载更多涨幅榜数据
-(void)loadMoreData{
    page = page + 1;
    NSString *urlStr = [NSString stringWithFormat:@"http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=%i&num=10&sort=changepercent&asc=0&node=hs_a&symbol=&_s_r_a=sort", page];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableview footerEndRefreshing];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        //
        NSString *searchText = obj;
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"[0-9]{2}:[0-9]{2}:[0-9]{2}\"" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *results = [regex matchesInString:searchText options:0 range:NSMakeRange(0, searchText.length)];
        
        if (results.count) {
            NSMutableArray *arrM = [NSMutableArray array];
            for (int i = 0; i < results.count; i++) {
                NSTextCheckingResult *result = results[i];
                NSString *str = [searchText substringWithRange:result.range];
                
                [arrM addObject:str];
            }
            
            for (int i = 0; i < arrM.count; i++) {
                searchText = [searchText stringByReplacingOccurrencesOfString:arrM[i] withString:@"11"];
            }
        }
        
        
        NSString *validString = [searchText stringByReplacingOccurrencesOfString:@"(\\w+)\\s*:([^a-zA-Z0-9_.:-]+)" withString:@"\"$1\":$2" options:NSRegularExpressionSearch range:NSMakeRange(0, [searchText length])];
        
        //SJLog(@"validString%@",validString);
        
        NSString *validString2 = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])(\\w+)\\s*:" withString:@"$1\"$2\":" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
        
        //SJLog(@"validString%@",validString2);
        
        NSData *data =[validString2 dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *arr7 =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        //SJLog(@"tmpDict%@",arr7);
        //SJLog(@"error%@",error);
        
        if (arr7.count) {
            [self.dataArray addObjectsFromArray:arr7];
        }
        
        [self.tableview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableview footerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SJselfSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    if (self.dataArray.count > indexPath.row) {
        cell.dict = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dictt = self.dataArray[indexPath.row];
    NSString *symbol = dictt[@"symbol"];
    NSString *type = [symbol substringToIndex:2];
    NSString *code = [NSString stringWithFormat:@"%@",dictt[@"code"]];
    NSString *name = dictt[@"name"];
    
    SJStockDetailContentViewController *stockDetailVC =[[SJStockDetailContentViewController alloc] init];
    stockDetailVC.code = code;
    stockDetailVC.name = name;
    stockDetailVC.type = type;
    [self.navigationController pushViewController:stockDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

@end

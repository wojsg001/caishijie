//
//  SJStockWeekLineViewController.m
//  QuartzDemo
//
//  Created by user on 16/9/22.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJStockWeekLineViewController.h"
#import "SJKLineView.h"
#import "AFNetworking.h"
#import "SJStockIndicatorView.h"

@interface SJStockWeekLineViewController ()

@property (nonatomic, strong) SJKLineView *kLineView;
@property (nonatomic, strong) SJStockIndicatorView *stockIndicatorView;

@end

@implementation SJStockWeekLineViewController

- (SJStockIndicatorView *)stockIndicatorView {
    if (!_stockIndicatorView) {
        _stockIndicatorView = [[SJStockIndicatorView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 250)];
    }
    return _stockIndicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _kLineView = [[SJKLineView alloc] initWithFrame:CGRectMake(10, 10, SJScreenW - 20, 230)];
    _kLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_kLineView];
    [self loadWeekLineData];
}

- (void)loadWeekLineData {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *urlStr = [NSString stringWithFormat:@"https://gupiao.baidu.com/api/stocks/stockweekbar?from=pc&os_ver=1&cuid=xxx&vv=100&format=json&stock_code=%@&step=3&start=&count=160&fq_type=no&timestamp=%ld", self.stock_code, (long)timeInterval];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.view addSubview:self.stockIndicatorView];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"成功%@", tmpDic);
        if ([tmpDic[@"errorMsg"] isEqualToString:@"SUCCESS"]) {
            NSArray *tmpArray = tmpDic[@"mashData"];
            if (tmpArray.count) {
                [self.stockIndicatorView removeFromSuperview];
                self.stockIndicatorView = nil;
                _kLineView.originalDataArray = [tmpArray copy];
                [_kLineView start];
            } else {
                [self.stockIndicatorView showAlertMessage:@"暂时无法获取数据"];
            }
        } else {
            [self.stockIndicatorView showAlertMessage:@"暂时无法获取数据"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败%@", error);
        [self.stockIndicatorView showAlertMessage:@"暂时无法获取数据"];
    }];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end

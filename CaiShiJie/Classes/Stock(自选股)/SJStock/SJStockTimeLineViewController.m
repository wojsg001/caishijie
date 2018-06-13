//
//  SJStockTimeLineViewController.m
//  QuartzDemo
//
//  Created by user on 16/9/22.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJStockTimeLineViewController.h"
#import "SJKLineView.h"
#import "AFNetworking.h"
#import "SJTimeLineView.h"
#import "SJTimeWuDangView.h"
#import <BlocksKit/NSArray+BlocksKit.h>
#import "SJStockIndicatorView.h"

#define KTimeLineViewWidth SJScreenW - 120

@interface SJStockTimeLineViewController ()

@property (nonatomic, strong) SJTimeLineView *timeLineView;
@property (nonatomic, strong) SJTimeWuDangView *timeWuDangView;
@property (nonatomic, strong) SJStockIndicatorView *stockIndicatorView;

@end

@implementation SJStockTimeLineViewController

- (SJStockIndicatorView *)stockIndicatorView {
    if (!_stockIndicatorView) {
        _stockIndicatorView = [[SJStockIndicatorView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 250)];
    }
    return _stockIndicatorView;
}

- (SJTimeWuDangView *)timeWuDangView {
    if (!_timeWuDangView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJStockUI" owner:nil options:nil];
        _timeWuDangView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJTimeWuDangView class]];
        }];
    }
    return _timeWuDangView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _timeLineView = [[SJTimeLineView alloc] initWithFrame:CGRectMake(10, 10, KTimeLineViewWidth, 230)];
    _timeLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_timeLineView];
    self.timeWuDangView.frame = CGRectMake(SJScreenW - 100, 10, 90, 230);
    [self.view addSubview:self.timeWuDangView];
    
    // 加载分时数据
    [self loadTimeLineData];
    // 接收更新数据的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimeLineData) name:KNotificationRefreshStockData object:nil];
}

- (void)loadTimeLineData {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *urlStr = [NSString stringWithFormat:@"https://gupiao.baidu.com/api/stocks/stocktimeline?from=pc&os_ver=1&cuid=xxx&vv=100&format=json&stock_code=%@&timestamp=%ld", self.stock_code, (long)timeInterval];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.view addSubview:self.stockIndicatorView];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        //SJLog(@"成功%@", tmpDic);
        if ([tmpDic[@"errorMsg"] isEqualToString:@"SUCCESS"]) {
            NSArray *tmpArray = tmpDic[@"timeLine"];
            if (tmpArray.count > 15) {
                [self.stockIndicatorView removeFromSuperview];
                self.stockIndicatorView = nil;
                // 前15个数据不要
                NSArray *timeLineArray = [tmpArray subarrayWithRange:NSMakeRange(15, tmpArray.count - 15)];
                _timeLineView.dataArray = [timeLineArray copy];
                _timeLineView.preClose = [tmpDic[@"preClose"] floatValue]; // 昨日收盘价
                [_timeLineView start];
                self.timeWuDangView.preClose = tmpDic[@"preClose"];
                self.timeWuDangView.sellArray = tmpDic[@"ask"];
                self.timeWuDangView.buyArray = tmpDic[@"bid"];
            } else {
                [self.stockIndicatorView showAlertMessage:@"暂时无法获取数据"];
            }
        } else {
            [self.stockIndicatorView showAlertMessage:@"暂时无法获取数据"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"失败%@", error);
        [self.stockIndicatorView showAlertMessage:@"暂时无法获取数据"];
    }];
}

- (void)updateTimeLineData {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *urlStr = [NSString stringWithFormat:@"https://gupiao.baidu.com/api/stocks/stocktimeline?from=pc&os_ver=1&cuid=xxx&vv=100&format=json&stock_code=%@&timestamp=%ld", self.stock_code, (long)timeInterval];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        //SJLog(@"成功%@", tmpDic);
        if ([tmpDic[@"errorMsg"] isEqualToString:@"SUCCESS"]) {
            NSArray *tmpArray = tmpDic[@"timeLine"];
            if (tmpArray.count > 15) {
                // 前15个数据不要
                NSArray *timeLineArray = [tmpArray subarrayWithRange:NSMakeRange(15, tmpArray.count - 15)];
                _timeLineView.dataArray = [timeLineArray copy];
                _timeLineView.preClose = [tmpDic[@"preClose"] floatValue]; // 昨日收盘价
                [_timeLineView update];
                self.timeWuDangView.preClose = tmpDic[@"preClose"];
                self.timeWuDangView.sellArray = tmpDic[@"ask"];
                self.timeWuDangView.buyArray = tmpDic[@"bid"];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"失败%@", error);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

//
//  SJStockDetailContentViewController.m
//  CaiShiJie
//
//  Created by user on 18/9/26.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJStockDetailContentViewController.h"
#import "SJStockHeadView.h"
#import "AFNetworking.h"
#import "UIColor+helper.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"

@interface SJStockDetailContentViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSTimer *_timer;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJStockHeadView *stockHeadView;
@property (nonatomic, strong) UIButton *addStockButton;

@end

@implementation SJStockDetailContentViewController

- (SJStockHeadView *)stockHeadView {
    if (!_stockHeadView) {
        _stockHeadView = [[NSBundle mainBundle] loadNibNamed:@"SJStockHeadView" owner:nil options:nil].lastObject;
        _stockHeadView.stock_code = [NSString stringWithFormat:@"%@%@", _type, _code];
    }
    return _stockHeadView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    self.navigationItem.title = [NSString stringWithFormat:@"%@(%@)", self.name, self.code];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stock_self_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(updateStockData)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self setupChildViews];
    // 加载数据
    [self loadStockData];
    if (APPDELEGATE.isNetworkReachableWiFi) {
        [self createNSTimer];
    }
    // 接收网络状态改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:KNotificationNetworkStatusChange object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelNSTimer];
}

- (void)setupChildViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 485)];
    self.stockHeadView.frame = tableHeaderView.bounds;
    [tableHeaderView addSubview:self.stockHeadView];
    self.tableView.tableHeaderView = tableHeaderView;
    
    _addStockButton = [[UIButton alloc] init];
    [_addStockButton setImage:[UIImage imageNamed:@"stock_add"] forState:UIControlStateNormal];
    [_addStockButton setTitle:@"添加自选" forState:UIControlStateNormal];
    [_addStockButton setTitleColor:RGB(247, 100, 8) forState:UIControlStateNormal];
    _addStockButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_addStockButton setBackgroundColor:[UIColor whiteColor]];
    _addStockButton.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    _addStockButton.layer.borderWidth = 0.5f;
    [_addStockButton addTarget:self action:@selector(addStockButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addStockButton];
    
    WS(weakSelf);
    [_addStockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(44);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.addStockButton.mas_top).offset(0);
    }];
}

#pragma mark - NSNotification
- (void)networkStatusChange:(NSNotification *)n {
    NSNumber *state = n.object;
    AFNetworkReachabilityStatus status = [state integerValue];
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        // 只有在WIFI下自动刷新数据
        [self createNSTimer];
    } else {
        [self cancelNSTimer];
    }
}

#pragma mark - 创建定时器
- (void)createNSTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(updateStockData) userInfo:nil repeats:YES];
}

- (void)updateStockData {
    SJLog(@"更新数据");
    [self loadStockData];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationRefreshStockData object:nil];
}

- (void)cancelNSTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)loadStockData {
    NSString *urlStr = [NSString stringWithFormat:@"http://qt.gtimg.cn/q=%@%@", self.type, self.code];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *jsonStr = [[NSString alloc] initWithData:responseObject encoding:encoding];
        NSArray *tempArray = [jsonStr componentsSeparatedByString:@"="];
        NSString *dataString = [tempArray objectAtIndex:1];
        NSArray *dataArray = [dataString componentsSeparatedByString:@"~"];
        //SJLog(@"dataArray:%@", dataArray);
        if (dataArray.count > 1) {
            self.stockHeadView.dataArray = dataArray;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"错误:%@", error);
    }];
}

#pragma mark - ClickEvent
- (void)addStockButtonClicked:(UIButton *)sender {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        SJToken *instance = [SJToken sharedToken];
        NSString *urlStr =[NSString stringWithFormat:@"%@/mobile/stock/addstock",HOST];
        NSDictionary *paramers = @{@"userid":instance.userid,@"time":instance.time,@"token":instance.token,@"code":self.code};
        [MBProgressHUD showMessage:@"添加中..." toView:self.view];
        [SJhttptool POST:urlStr paramers:paramers success:^(id respose) {
            [MBProgressHUD hideHUDForView:self.view];
            if ([respose[@"states"] isEqualToString:@"1"]) {
                [MBProgressHUD showSuccess:@"加入成功"];
                [self.addStockButton setImage:[UIImage imageNamed:@"stock_add_h"] forState:UIControlStateNormal];
                [self.addStockButton setTitleColor:RGB(179, 179, 179) forState:UIControlStateNormal];
                self.addStockButton.enabled = NO;
            } else {
                [MBHUDHelper showWarningWithText:respose[@"data"]];
            }
        } failure:^(NSError *error) {
            SJLog(@"%@", error);
            [MBProgressHUD hideHUDForView:self.view];
            [MBHUDHelper showWarningWithText:@"连接超时"];
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

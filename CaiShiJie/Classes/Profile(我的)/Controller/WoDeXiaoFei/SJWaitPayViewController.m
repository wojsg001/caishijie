//
//  SJWaitPayViewController.m
//  CaiShiJie
//
//  Created by user on 16/3/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJWaitPayViewController.h"
#import "SJWaitPayCell.h"
#import "SJNetManager.h"
#import "SJToken.h"
#import "SJUserConsumeParam.h"
#import "SJBillModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJNetManager.h"
#import "SJMixPayParam.h"
#import "SJPayView.h"
#import "SJGoldPay.h"
#import "SJGiftModel.h"

@interface SJWaitPayViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    SJNetManager *netManager;
    int j; // 分页
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
// 存放账单
@property (nonatomic, strong) NSMutableArray *billArray;
@property (nonatomic, strong) SJBillModel *curSelModel;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJWaitPayViewController

- (NSMutableArray *)billArray
{
    if (_billArray == nil) {
        _billArray = [NSMutableArray array];
    }
    return _billArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    netManager = [SJNetManager sharedNetManager];
    self.isNetwork = YES;
    // 设置表格属性
    [self setUpTableView];
    // 加载待支付账单数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadWaitConsumeData];
    
    // 添加下拉刷新和上拉加载
    [self.tableView addHeaderWithTarget:self action:@selector(loadWaitConsumeData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreWaitConsumeData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";

    self.payButton.layer.cornerRadius = 5;
    self.payButton.layer.masksToBounds = YES;
    self.bottomView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
    self.bottomView.layer.borderWidth = 0.5f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshNetwork];
}

#pragma mark - 加载待支付账单数据
- (void)loadWaitConsumeData
{
    j = 1;
    
    SJToken *instance = [SJToken sharedToken];

    SJUserConsumeParam *consumeParam = [[SJUserConsumeParam alloc] init];
    consumeParam.pageindex = [NSString stringWithFormat:@"%i",j];
    consumeParam.pagesize = @"10";
    consumeParam.status = @"3";
    consumeParam.type = @"1";
    consumeParam.token = instance.token;
    consumeParam.userid = instance.userid;
    consumeParam.time = instance.time;
    
    [netManager requestUserConsumeWithParam:consumeParam success:^(NSDictionary *dict) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"待支付：%@",dict);
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        NSArray *tmpArray = [SJBillModel objectArrayWithKeyValuesArray:dict[@"order"]];
        if (tmpArray.count) {
            [self.billArray removeAllObjects];
            [self.billArray addObjectsFromArray:tmpArray];
            [self.tableView reloadData];
        }

        if (!self.billArray.count) {
            // 如果没有数据，显示提示页
            [SJNoDataView showNoDataViewToView:self.view];
        } else {
            [SJNoDataView hideNoDataViewFromView:self.view];
        }
        
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多待支付账单数据
- (void)loadMoreWaitConsumeData
{
    j++;
    
    SJToken *instance = [SJToken sharedToken];
    
    SJUserConsumeParam *consumeParam = [[SJUserConsumeParam alloc] init];
    consumeParam.pageindex = [NSString stringWithFormat:@"%i",j];
    consumeParam.pagesize = @"10";
    consumeParam.status = @"3";
    consumeParam.type = @"1";
    consumeParam.token = instance.token;
    consumeParam.userid = instance.userid;
    consumeParam.time = instance.time;
    
    [netManager requestUserConsumeWithParam:consumeParam success:^(NSDictionary *dict) {
        [self.tableView footerEndRefreshing];
        
        NSArray *tmpArray = [SJBillModel objectArrayWithKeyValuesArray:dict[@"order"]];
        if (tmpArray.count) {
            [self.billArray addObjectsFromArray:tmpArray];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    
    UINib *nib = [UINib nibWithNibName:@"SJWaitPayCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SJWaitPayCell"];
   }

#pragma mark - UITableViewDataSource 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.billArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJWaitPayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJWaitPayCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.billModel = self.billArray[indexPath.row];
    
    if (self.lastSelIndexPath != nil) {
        if (self.lastSelIndexPath.row == indexPath.row) {
            cell.selectedView.hidden = NO;
        } else {
            cell.selectedView.hidden = YES;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJBillModel *billModel = self.billArray[indexPath.row];
    if ([billModel.user_account_type isEqualToString:@"0"]) {
        
        NSInteger newSel = indexPath.row;
        NSInteger oldSel = self.lastSelIndexPath.row;
        if (newSel != oldSel || self.lastSelIndexPath == nil) {
            // 新选中的cell
            SJWaitPayCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.selectedView.hidden = NO;
            // 之前选中的cell
            SJWaitPayCell *oldCell = [tableView cellForRowAtIndexPath:self.lastSelIndexPath];
            oldCell.selectedView.hidden = YES;
            
            self.lastSelIndexPath = indexPath;
            // 选中的model
            _curSelModel = self.billArray[indexPath.row];
        }
    } else {
        [MBHUDHelper showWarningWithText:@"订单不可用,请重新下单!"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (IBAction)payButtonClicked:(UIButton *)sender {
    if (_curSelModel == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请选择要支付的订单" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    SJGiftModel *model = [[SJGiftModel alloc] init];
    model.gift_id = _curSelModel.item_id;
    model.price = _curSelModel.price;
    NSString *item_type = _curSelModel.item_type;
    NSString *item_name = @"";
    if ([item_type isEqualToString:@"1"]) {
        //礼物名称
        item_name = _curSelModel.item_name;
    } else if ([item_type isEqualToString:@"2"]){
        item_name = @"红包";
    } else if ([item_type isEqualToString:@"3"]){
        item_name = @"上香";
    } else if ([item_type isEqualToString:@"20"]){
        item_name = @"内参";
    } else if ([item_type isEqualToString:@"0"]){
        item_name = @"充值";
    }
    model.gift_name = item_name;
    //seller_id:user_id?
    [SJPayView showSJPayViewWithGiftModel:model targetid:_curSelModel.user_id itemtype:item_type];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadWaitConsumeData];
    }
}

@end

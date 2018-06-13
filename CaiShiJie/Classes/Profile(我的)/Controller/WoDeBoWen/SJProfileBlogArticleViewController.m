//
//  SJProfileBlogArticleViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJProfileBlogArticleViewController.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJLogDetailViewController.h"
#import "SJCreateNewBlogArticleViewController.h"
#import "SJMySendBlogArticleCell.h"
#import "SJMyDraftBlogArticleCell.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "SJMyBlogArticleModel.h"

@interface SJProfileBlogArticleViewController ()<UITableViewDataSource,UITableViewDelegate,SJNoWifiViewDelegate>
{
    int i; // 已发博文分页
    int j; // 草稿箱博文分页
    NSInteger curSelIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableArray *sendBlogArticleArr;
@property (nonatomic, strong) NSMutableArray *draftBlogArticleArr;

@end

@implementation SJProfileBlogArticleViewController

- (NSMutableArray *)sendBlogArticleArr {
    if (_sendBlogArticleArr == nil) {
        _sendBlogArticleArr = [NSMutableArray array];
    }
    return _sendBlogArticleArr;
}

- (NSMutableArray *)draftBlogArticleArr {
    if (_draftBlogArticleArr == nil) {
        _draftBlogArticleArr = [NSMutableArray array];
    }
    return _draftBlogArticleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格
    [self setUpTableView];
    // 设置分段选择控件
    [self setUpSegmentedControl];
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadBlogArticleData)];
    // 添加下拉获取更多数据
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreBlogArticleData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
    // 开始加载
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadBlogArticleData];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_inner_fabu"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewBlogArticle)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 下拉刷新
- (void)loadBlogArticleData {
    if (curSelIndex == 0) {
        [self loadSendBlogArticleData];
    } else if (curSelIndex == 1) {
        [self loadDraftBlogArticleData];
    }
}

#pragma mark - 上拉刷新
- (void)loadMoreBlogArticleData {
    if (curSelIndex == 0) {
        [self loadMoreSendBlogArticleData];
    } else if (curSelIndex == 1) {
        [self loadMoreDraftBlogArticleData];
    }
}

- (void)setUpTableView {
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.estimatedRowHeight = 156;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    UINib *nib1 = [UINib nibWithNibName:@"SJMySendBlogArticleCell" bundle:nil];
    [_tableView registerNib:nib1 forCellReuseIdentifier:@"SJMySendBlogArticleCell"];
    UINib *nib2 = [UINib nibWithNibName:@"SJMyDraftBlogArticleCell" bundle:nil];
    [_tableView registerNib:nib2 forCellReuseIdentifier:@"SJMyDraftBlogArticleCell"];
}

// 设置分段选择控件
- (void)setUpSegmentedControl {
    // 设置边框
    _segmentedControl.layer.borderColor = RGB(247, 100, 8).CGColor;
    _segmentedControl.layer.borderWidth = 1.0f;
    // 设置圆角
    _segmentedControl.layer.cornerRadius = 5.0;
    _segmentedControl.layer.masksToBounds = YES;
    // 背景色
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    // 选中色
    _segmentedControl.tintColor = RGB(247, 100, 8);
    // 设置默认状态字体大小和颜色
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    attributes[NSForegroundColorAttributeName] = RGB(247, 100, 8);
    [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    // 设置选择状态时的大小和颜色
    attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateSelected];
    
    // 设置在点击后是否恢复原样
    _segmentedControl.momentary = NO;
    // 默认选中第0个
    _segmentedControl.selectedSegmentIndex = 0;
    curSelIndex = 0;
    
    [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentAction:(UISegmentedControl *)seg {
    curSelIndex = seg.selectedSegmentIndex;
    switch (curSelIndex) {
        case 0:
        {
            [MBProgressHUD showMessage:@"加载中..." toView:self.view];
            [self loadBlogArticleData];
        }
            break;
        case 1:
        {
            [MBProgressHUD showMessage:@"加载中..." toView:self.view];
            [self loadBlogArticleData];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 创建新的博文
- (void)createNewBlogArticle {
    SJCreateNewBlogArticleViewController *createNewBlogArticleVC = [[SJCreateNewBlogArticleViewController alloc] init];
    createNewBlogArticleVC.title = @"发表博文";
    
    [self.navigationController pushViewController:createNewBlogArticleVC animated:YES];
}

#pragma mark - 加载已发送博文数据
- (void)loadSendBlogArticleData {
    i = 1;
    
    SJToken *instance = [SJToken sharedToken];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbyuserid",HOST];
    NSString *pageindex = [NSString stringWithFormat:@"%i",i];
    NSDictionary *paramDic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"type":@"1",@"pageindex":pageindex,@"pagesize":@"5"};
    
    [SJhttptool GET:urlStr paramers:paramDic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJMyBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            
            if (tmpArr.count) {
                [self.sendBlogArticleArr removeAllObjects];
                [self.sendBlogArticleArr addObjectsFromArray:tmpArr];
            }
            
            [self.tableView reloadData];
            // 如果没有数据显示默认页
            if (!self.sendBlogArticleArr.count) {
                self.noDataView.hidden = NO;
            } else {
                self.noDataView.hidden = YES;
            }
        } else {
            [MBHUDHelper showWarningWithText:@"请求失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        SJLog(@"%@",error);
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - 加载更多已发送博文数据
- (void)loadMoreSendBlogArticleData {
    i = i + 1;
    
    SJToken *instance = [SJToken sharedToken];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbyuserid",HOST];
    NSString *pageindex = [NSString stringWithFormat:@"%i",i];
    NSDictionary *paramDic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"type":@"1",@"pageindex":pageindex,@"pagesize":@"5"};
    
    [SJhttptool GET:urlStr paramers:paramDic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJMyBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            
            if (tmpArr.count) {
                [self.sendBlogArticleArr addObjectsFromArray:tmpArr];
            }
            [self.tableView reloadData];
        } else {
            [MBHUDHelper showWarningWithText:@"请求失败！"];
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        SJLog(@"%@",error);
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - 加载草稿箱博文数据
- (void)loadDraftBlogArticleData {
    j = 1;
    
    SJToken *instance = [SJToken sharedToken];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbyuserid",HOST];
    NSString *pageindex = [NSString stringWithFormat:@"%i",j];
    NSDictionary *paramDic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"type":@"0",@"pageindex":pageindex,@"pagesize":@"5"};
    
    [SJhttptool GET:urlStr paramers:paramDic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJMyBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            
            if (tmpArr.count) {
                [self.draftBlogArticleArr removeAllObjects];
                [self.draftBlogArticleArr addObjectsFromArray:tmpArr];
            }
            [self.tableView reloadData];
            
            // 如果没有数据显示默认页
            if (!self.draftBlogArticleArr.count) {
                self.noDataView.hidden = NO;
            } else {
                self.noDataView.hidden = YES;
            }
        } else {
            [MBHUDHelper showWarningWithText:@"请求失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        SJLog(@"%@",error);
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - 加载更多草稿箱博文数据
- (void)loadMoreDraftBlogArticleData {
    j = j + 1;
    
    SJToken *instance = [SJToken sharedToken];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbyuserid",HOST];
    NSString *pageindex = [NSString stringWithFormat:@"%i",j];
    NSDictionary *paramDic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"type":@"0",@"pageindex":pageindex,@"pagesize":@"5"};
    
    [SJhttptool GET:urlStr paramers:paramDic success:^(id respose) {
        [self.tableView footerEndRefreshing];
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJMyBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            
            if (tmpArr.count) {
                [self.draftBlogArticleArr addObjectsFromArray:tmpArr];
            }
            [self.tableView reloadData];
        } else {
            [MBHUDHelper showWarningWithText:@"请求失败！"];
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        SJLog(@"%@",error);
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (curSelIndex == 0) {
        return self.sendBlogArticleArr.count;
    } else if (curSelIndex == 1) {
        return self.draftBlogArticleArr.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (curSelIndex == 0) {
        SJMySendBlogArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJMySendBlogArticleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.sendBlogArticleArr.count) {
            SJMyBlogArticleModel *blogArticleModel = self.sendBlogArticleArr[indexPath.row];
            cell.blogArticleModel = blogArticleModel;
        }
        
        return cell;
    } else if (curSelIndex == 1) {
        SJMyDraftBlogArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJMyDraftBlogArticleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.draftBlogArticleArr.count) {
            SJMyBlogArticleModel *blogArticleModel = self.draftBlogArticleArr[indexPath.row];
            cell.blogArticleModel = blogArticleModel;
        }
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (curSelIndex == 0) {
        SJMyBlogArticleModel *blogArticleModel = self.sendBlogArticleArr[indexPath.row];
    
        SJLogDetailViewController *detailVC = [[SJLogDetailViewController alloc] initWithNibName:@"SJLogDetailViewController" bundle:nil];
        detailVC.article_id = blogArticleModel.article_id;
        detailVC.isOwnArticle = YES;
    
        [self.navigationController pushViewController:detailVC animated:YES];
    } else if (curSelIndex == 1) {
        SJMyBlogArticleModel *blogArticleModel = self.draftBlogArticleArr[indexPath.row];
        
        SJCreateNewBlogArticleViewController *createNewBlogArticleVC = [[SJCreateNewBlogArticleViewController alloc] init];
        createNewBlogArticleVC.title = @"编辑";
        createNewBlogArticleVC.blogArticleModel = blogArticleModel;
        
        [self.navigationController pushViewController:createNewBlogArticleVC animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadBlogArticleData];
}

@end

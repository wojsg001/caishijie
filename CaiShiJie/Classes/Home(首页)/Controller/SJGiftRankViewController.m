//
//  SJGiftRankViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGiftRankViewController.h"
#import "SJGiftRankCell.h"
#import "SJGiveGiftViewController.h"
#import "SJhttptool.h"
#import "SJGiftRankModel.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface SJGiftRankViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int i;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJGiftRankViewController

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格
    [self setUpTableView];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadGiftRankData];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadGiftRankData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreGiftRankData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.tableFooterView = [UIView new];
}

#pragma mark - 加载数据
- (void)loadGiftRankData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/giftranking",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"20"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJGiftRankModel objectArrayWithKeyValuesArray:respose[@"data"][@"teacher"]];
            if (tmpArr.count)
            {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
    }];
}

#pragma mark - 加载更多数据
- (void)loadMoreGiftRankData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/giftranking",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"10"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"%@",respose);
        [self.tableView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJGiftRankModel objectArrayWithKeyValuesArray:respose[@"data"][@"teacher"]];
            if (tmpArr.count)
            {
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.tableView footerEndRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJGiftRankCell *cell = [SJGiftRankCell cellWithTableView:tableView];
    cell.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
    
    if (indexPath.row == 0)
    {
        cell.sortLabel.textColor = RGB(255, 178, 45);
    }
    else if (indexPath.row == 1)
    {
        cell.sortLabel.textColor = RGB(217, 67, 50);
    }
    else if (indexPath.row == 2)
    {
        cell.sortLabel.textColor = RGB(24, 181, 238);
    }
    else
    {
        cell.sortLabel.textColor = RGB(153, 153, 153);
    }
    
    if (self.dataArray.count)
    {
        SJGiftRankModel *model = self.dataArray[indexPath.row];
        
        cell.sortLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
        [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,model.head_img]] placeholderImage:[UIImage imageNamed:@"rank_gift_pho"]];
        cell.nameLabel.text = model.nickname;
        cell.giftCountLabel.text = model.counts;
        
        cell.sendButton.tag = indexPath.row + 101;
        [cell.sendButton addTarget:self action:@selector(sendButtonClickDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - 点击送礼按钮
- (void)sendButtonClickDown:(UIButton *)sender
{
    SJGiftRankModel *model = self.dataArray[sender.tag - 101];
    
    SJGiveGiftViewController *giveGiftVC = [[SJGiveGiftViewController alloc] init];
    giveGiftVC.navigationItem.title = [NSString stringWithFormat:@"给「%@」送礼",model.nickname];
    giveGiftVC.targetid = model.user_id;
    
    [self.navigationController pushViewController:giveGiftVC animated:YES];
}

@end

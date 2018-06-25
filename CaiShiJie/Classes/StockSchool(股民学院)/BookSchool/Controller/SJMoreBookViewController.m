//
//  SJMoreBookViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMoreBookViewController.h"
#import "SJRecommendBookCell.h"
#import "SJhttptool.h"
#import "SJBookListModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SJBookDetailViewController.h"

@interface SJMoreBookViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    int i; // 分页
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJMoreBookViewController

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
    
    // 设置CollectionView属性
    [self setUpCollectionView];
    
    if ([self.title isEqualToString:@"基础入门"])
    {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadBasisBookData];
    }
    else if ([self.title isEqualToString:@"技术分析"])
    {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadTechnologyBookData];
    }
    
    // 添加上拉刷新
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreBookData)];
    self.collectionView.footerRefreshingText = @"正在加载...";
    
}
#pragma mark - 上拉刷新
- (void)loadMoreBookData
{
    if ([self.title isEqualToString:@"基础入门"])
    {
        [self loadMoreBasisBookData];
    }
    else if ([self.title isEqualToString:@"技术分析"])
    {
        [self loadMoreTechnologyBookData];
    }
}

- (void)loadBasisBookData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/book/index",HOST];
    NSDictionary *dic = @{@"type":@"0",@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"8"};
    SJLog(@"%@",urlStr);
    
    SJLog(@"%@",dic);
    // 基础入门
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJBookListModel objectArrayWithKeyValuesArray:respose[@"data"][@"books"]];
            if (tmpArr.count)
            {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
            }
            
            [self.collectionView reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)loadMoreBasisBookData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/book/index",HOST];
    NSDictionary *dic = @{@"type":@"0",@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"8"};
    SJLog(@"%@",urlStr);
    
    SJLog(@"%@",dic);
    // 基础入门
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.collectionView footerEndRefreshing];
        SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJBookListModel objectArrayWithKeyValuesArray:respose[@"data"][@"books"]];
            SJLog(@"--%@",tmpArr);
            if (tmpArr.count)
            {
                [self.dataArray addObjectsFromArray:tmpArr];
            }
            
            [self.collectionView reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.collectionView footerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)loadTechnologyBookData
{
    i = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/book/index",HOST];
    NSDictionary *dic = @{@"type":@"1",@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"8"};
    // 技术分析
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJBookListModel objectArrayWithKeyValuesArray:respose[@"data"][@"books"]];
            if (tmpArr.count)
            {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArr];
            }
            
            [self.collectionView reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)loadMoreTechnologyBookData
{
    i = i + 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/book/index",HOST];
    NSDictionary *dic = @{@"type":@"1",@"pageindex":[NSString stringWithFormat:@"%i",i],@"pagesize":@"8"};
    // 技术分析
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.collectionView footerEndRefreshing];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJBookListModel objectArrayWithKeyValuesArray:respose[@"data"][@"books"]];
            SJLog(@"++%@",tmpArr);
            if (tmpArr.count)
            {
                [self.dataArray addObjectsFromArray:tmpArr];
            }
            
            [self.collectionView reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [self.collectionView footerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)setUpCollectionView
{
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"SJRecommendBookCell" bundle:nil] forCellWithReuseIdentifier:@"SJRecommendBookCell"];
}

#pragma mark - UICollectionViewDataSource 代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SJRecommendBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJRecommendBookCell" forIndexPath:indexPath];
    
    if (self.dataArray.count)
    {
        SJBookListModel *bookListModel = self.dataArray[indexPath.row];
        cell.bookListModel = bookListModel;
    }
    
    return cell;
}

//协议中的方法，用于返回单元格的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SJScreenW - 30) / 2, (SJScreenW - 30) / 2 + 50);
}

//协议中的方法，用于返回整个CollectionView上、左、下、右距四边的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //上、左、下、右的边距
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SJBookListModel *bookListModel = self.dataArray[indexPath.row];
    
    SJBookDetailViewController *bookDetailVC = [[SJBookDetailViewController alloc] init];
    bookDetailVC.title = @"简介";
    bookDetailVC.bookListModel = bookListModel;
    
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

@end

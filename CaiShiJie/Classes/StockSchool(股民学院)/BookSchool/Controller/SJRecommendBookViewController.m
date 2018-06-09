//
//  SJRecommendBookViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJRecommendBookViewController.h"
#import "SJBookGroupSectionView.h"
#import "SJRecommendBookCell.h"
#import "SJMoreBookViewController.h"
#import "SJBookDetailViewController.h"
#import "SJhttptool.h"
#import "SJBookListModel.h"
#import "MJExtension.h"

@interface SJRecommendBookViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
// 标题数组
@property (nonatomic, strong) NSArray *sectionArray;
// 基础入门
@property (nonatomic, strong) NSMutableArray *basisArray;
// 技术分析
@property (nonatomic, strong) NSMutableArray *technologyArray;

@end

@implementation SJRecommendBookViewController

- (NSMutableArray *)basisArray
{
    if (_basisArray == nil)
    {
        _basisArray = [NSMutableArray array];
    }
    return _basisArray;
}

- (NSMutableArray *)technologyArray
{
    if (_technologyArray == nil)
    {
        _technologyArray = [NSMutableArray array];
    }
    return _technologyArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"书籍推荐";
    self.sectionArray = @[@"基础入门", @"技术分析"];
    // 设置CollectionView属性
    [self setUpCollectionView];
    
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadRecommendBookData];
}

- (void)loadRecommendBookData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/book/index",HOST];
    NSDictionary *dic = @{@"type":@"0",@"pageindex":@"1",@"pagesize":@"4"};
    // 基础入门
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJBookListModel objectArrayWithKeyValuesArray:respose[@"data"][@"books"]];
            [self.basisArray addObjectsFromArray:tmpArr];
            
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
    // 技术分析
    dic = @{@"type":@"1",@"pageindex":@"1",@"pagesize":@"4"};
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJBookListModel objectArrayWithKeyValuesArray:respose[@"data"][@"books"]];
            [self.technologyArray addObjectsFromArray:tmpArr];
            
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

- (void)setUpCollectionView
{
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"SJRecommendBookCell" bundle:nil] forCellWithReuseIdentifier:@"SJRecommendBookCell"];
    
    //参数二：用来区分是分组头还是分组脚
    [_collectionView registerNib:[UINib nibWithNibName:@"SJBookGroupSectionView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SJBookGroupSectionView"];
}

#pragma mark - UICollectionViewDataSource 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.basisArray.count;
    }
    else if (section == 1)
    {
        return self.technologyArray.count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SJRecommendBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJRecommendBookCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        if (self.basisArray.count)
        {
            SJBookListModel *bookListModel = self.basisArray[indexPath.row];
            cell.bookListModel = bookListModel;
        }
    }
    else if (indexPath.section == 1)
    {
        if (self.technologyArray.count)
        {
            SJBookListModel *bookListModel = self.technologyArray[indexPath.row];
            cell.bookListModel = bookListModel;
        }
    }
    
    return cell;
}

//协议中的方法，用于返回单元格的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SJScreenW - 30) / 2, ((SJScreenW - 30) / 2) * 300/345 + 50);
}

//协议中的方法，用于返回整个CollectionView上、左、下、右距四边的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //上、左、下、右的边距
    return UIEdgeInsetsMake(5, 10, 10, 10);
}

//协议中的方法，用来返回分组头的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //宽度随便定，系统会自动取collectionView的宽度
    //高度为分组头的高度
    return CGSizeMake(0, 40);
}

//参数二：用来区分是分组头还是分组脚
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SJBookGroupSectionView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SJBookGroupSectionView" forIndexPath:indexPath];
    header.titleLabel.text = _sectionArray[indexPath.section];
    
    header.moreButton.tag = indexPath.section + 101;
    [header.moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return header;
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
    SJBookListModel *bookListModel = nil;
    if (indexPath.section == 0)
    {
        bookListModel = self.basisArray[indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        bookListModel = self.technologyArray[indexPath.row];
    }
    
    SJBookDetailViewController *bookDetailVC = [[SJBookDetailViewController alloc] init];
    bookDetailVC.title = @"简介";
    bookDetailVC.bookListModel = bookListModel;
    
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

- (void)moreButtonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 101:
        {
            SJMoreBookViewController *moreBookVC = [[SJMoreBookViewController alloc] init];
            moreBookVC.title = @"基础入门";
            
            [self.navigationController pushViewController:moreBookVC animated:YES];
        }
            break;
        case 102:
        {
            SJMoreBookViewController *moreBookVC = [[SJMoreBookViewController alloc] init];
            moreBookVC.title = @"技术分析";
            
            [self.navigationController pushViewController:moreBookVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end

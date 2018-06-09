//
//  SJNewBlogArticleViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJNewBlogArticleViewController.h"
#import "SJBlogArticleTopView.h"
#import "SJBlogArticleWonderfulView.h"
#import "SJRecommendBlogArticleView.h"
#import "SJBlogArticleHeaderView.h"
#import "SJBlogArticleListViewController.h"
#import "SJhttptool.h"
#import "SJBlogArticleModel.h"
#import "MJExtension.h"
#import "SJLogDetailViewController.h"
#import "SJBlogZhuanTiModel.h"
#import "KINWebBrowserViewController.h"

@interface SJNewBlogArticleViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,SJBlogArticleTopViewDelegate,SJRecommendBlogArticleViewDelegate,KINWebBrowserDelegate,SJNoWifiViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *headerArr;
// 存放推荐博文数据
@property (nonatomic, strong) NSArray *blogArticleArray;
@property (nonatomic, strong) NSArray *blogZhuanTiArray;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJNewBlogArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isNetwork = YES;
    // 设置CollectionView
    [self setUpCollectionView];
    self.headerArr = @[@{@"icon":@"article_nav_icon1",@"title":@"早晚评"},
                       @{@"icon":@"article_nav_icon3",@"title":@"抓牛股"},
                       @{@"icon":@"article_nav_icon4",@"title":@"晒战绩"},
                       @{@"icon":@"article_nav_icon5",@"title":@"独家专栏"},
                       @{@"icon":@"article_nav_icon6",@"title":@"精彩专题"},
                       @{@"icon":@"article_nav_icon7",@"title":@"点击量排行"}];
    
    // 加载股评数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadBlogArticleData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshNetwork];
}

#pragma mark - 加载股评数据
- (void)loadBlogArticleData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/home/article?subjectSize=%i&articleSize=%i",HOST ,5 , 6];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            // 推荐博文
            self.blogArticleArray = [SJBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"ElectArticle"]];
            // 推荐专题
            self.blogZhuanTiArray = [SJBlogZhuanTiModel objectArrayWithKeyValuesArray:respose[@"data"][@"ElectSubject"]];
            [self.collectionView reloadData];
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)setUpCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [_collectionView registerClass:[SJBlogArticleTopView class] forCellWithReuseIdentifier:@"SJBlogArticleTopView"];
    [_collectionView registerClass:[SJBlogArticleWonderfulView class] forCellWithReuseIdentifier:@"SJBlogArticleWonderfulView"];
    [_collectionView registerClass:[SJRecommendBlogArticleView class] forCellWithReuseIdentifier:@"SJRecommendBlogArticleView"];
    
    [self.view addSubview:_collectionView];
    WS(weakSelf);
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SJBlogArticleTopView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJBlogArticleTopView" forIndexPath:indexPath];
        cell.delegate = self;
        
        if (!cell.contentModelArray.count) {
            cell.contentModelArray = self.headerArr;
        }
        
        return cell;
    } else if (indexPath.row == 1) {
        SJBlogArticleWonderfulView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJBlogArticleWonderfulView" forIndexPath:indexPath];
        cell.headerView.iconImage.image = [UIImage imageNamed:@"article_nav_icon"];
        cell.headerView.titleLabel.text = @"精彩专题";
        cell.headerView.moreBtn.tag = indexPath.row + 100;
        [cell.headerView.moreBtn addTarget:self action:@selector(clickMoreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!cell.contentModelArray.count) {
            cell.contentModelArray = self.blogZhuanTiArray;
            
            cell.blogArticleWonderfulViewBlock = ^(NSInteger row){
                
                SJBlogZhuanTiModel *model = self.blogZhuanTiArray[row];
                KINWebBrowserViewController *webBrowserVC = [KINWebBrowserViewController webBrowser];
                [webBrowserVC setDelegate:self];
                [webBrowserVC loadURLString:model.url];
                webBrowserVC.tintColor = [UIColor whiteColor];
                
                [self.navigationController pushViewController:webBrowserVC animated:YES];
                
            };
        }
        
        return cell;
    } else if (indexPath.row == 2) {
        SJRecommendBlogArticleView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJRecommendBlogArticleView" forIndexPath:indexPath];
        cell.headerView.iconImage.image = [UIImage imageNamed:@"article_nav_icon2"];
        cell.headerView.titleLabel.text = @"推荐股评";
        cell.delegate = self;
        
        cell.headerView.moreBtn.tag = indexPath.row + 100;
        [cell.headerView.moreBtn addTarget:self action:@selector(clickMoreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!cell.contentModelArray.count) {
            cell.contentModelArray = self.blogArticleArray;
        }
        
        return cell;
    }
    
    return [UICollectionViewCell new];
}

- (void)clickMoreButtonDown:(UIButton *)sender {
    SJBlogArticleListViewController *blogArticleListVC = [[SJBlogArticleListViewController alloc] init];
    
    switch (sender.tag) {
        case 101:
            
            blogArticleListVC.selectedIndex = 4;
            [self.navigationController pushViewController:blogArticleListVC animated:YES];
            
            break;
        case 102:
            
            blogArticleListVC.selectedIndex = 0;
            [self.navigationController pushViewController:blogArticleListVC animated:YES];
            
            break;
            
        default:
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return CGSizeMake(SJScreenW, 208);
    } else if (indexPath.row == 1) {
        return CGSizeMake(SJScreenW, 160);
    } else if (indexPath.row == 2) {
        return CGSizeMake(SJScreenW, self.blogArticleArray.count * 110 + 35);
    }
    
    return CGSizeZero;
}

#pragma mark - SJBlogArticleTopViewDelegate
- (void)blogArticleTopView:(SJBlogArticleTopView *)blogArticleTopView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SJBlogArticleListViewController *blogArticleListVC = [[SJBlogArticleListViewController alloc] init];
    blogArticleListVC.selectedIndex = indexPath.row;
    
    [self.navigationController pushViewController:blogArticleListVC animated:YES];
    
}

#pragma mark - SJRecommendBlogArticleViewDelegate
- (void)recommendBlogArticleView:(SJRecommendBlogArticleView *)recommendBlogArticleView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SJBlogArticleModel *model = self.blogArticleArray[indexPath.row];
    SJLogDetailViewController *detailVC = [[SJLogDetailViewController alloc] initWithNibName:@"SJLogDetailViewController" bundle:nil];
    detailVC.article_id = model.article_id;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - KINWebBrowserDelegate
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error {
    [MBHUDHelper showWarningWithText:@"加载失败！"];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadBlogArticleData];
    }
}

@end

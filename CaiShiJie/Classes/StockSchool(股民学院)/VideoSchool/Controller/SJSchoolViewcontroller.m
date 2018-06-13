//
//  SJschoolViewcontroller.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJschoolViewcontroller.h"
#import "SJFirstsectionCell.h"
#import "SJsecondsectionCell.h"
#import "SJCollectionHeadview.h"
#import "MorevideoViewController.h"
#import "SJVideoViewController.h"
#import "SJhttptool.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "SJRecommendBookViewController.h"
#import "SJSchoolVideoModel.h"
#import "MJExtension.h"

@interface SJSchoolViewcontroller ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SJCollectionHeadviewdelegate,SJNoWifiViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *newVideoArray;
@property (nonatomic, strong) NSMutableArray *hotVideoArray;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJSchoolViewcontroller

- (NSMutableArray *)newVideoArray {
    if (_newVideoArray == nil) {
        _newVideoArray = [NSMutableArray array];
    }
    return _newVideoArray;
}

- (NSMutableArray *)hotVideoArray {
    if (_hotVideoArray == nil) {
        _hotVideoArray = [NSMutableArray array];
    }
    return _hotVideoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"股民学院";
    self.isNetwork = YES;
    [self initsubviews];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshNetwork];
}

- (void)initsubviews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH - HEIGHT_TABBAR - HEIGHT_STATUSBAR - HEIGHT_NAVBAR) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];
    
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"SJFirstsectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell1"];
    [_collectionView registerNib:[UINib nibWithNibName:@"SJsecondsectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell2"];
    //注册headview
    [_collectionView registerNib:[UINib nibWithNibName:@"SJCollectionHeadview" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
}

#pragma mark - 加载数据
- (void)loadVideoData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/home/video", HOST];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [self.collectionView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *newVideoArray = [SJSchoolVideoModel objectArrayWithKeyValuesArray:respose[@"data"][@"VideoNew"]];
            if (newVideoArray.count) {
                [self.newVideoArray removeAllObjects];
                [self.newVideoArray addObjectsFromArray:newVideoArray];
            }
            NSArray *hotVideoAray = [SJSchoolVideoModel objectArrayWithKeyValuesArray:respose[@"data"][@"VideoHot"]];
            if (hotVideoAray.count) {
                [self.hotVideoArray removeAllObjects];
                [self.hotVideoArray addObjectsFromArray:hotVideoAray];
            }
            [self.collectionView reloadData];
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [self.collectionView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark collectiondelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return self.newVideoArray.count;
    } else {
        return  self.hotVideoArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SJFirstsectionCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell1.headimage.image = [UIImage imageNamed:@"school_nav_icon1"
            ];
            cell1.namelable.text = @"课程视频";
        } else if (indexPath.row == 1) {
            cell1.headimage.image = [UIImage imageNamed:@"school_nav_icon2"];
            cell1.namelable.text = @"书籍推荐";
        } else {
            cell1.headimage.image = [UIImage imageNamed:@"school_nav_icon3"];
            cell1.namelable.text = @"原创类";
        }
        
        return cell1;
    } else if (indexPath.section == 1) {
        SJsecondsectionCell *cell2 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        if (self.newVideoArray.count) {
            cell2.model = self.newVideoArray[indexPath.row];
        }
    
        return cell2;
    } else {
        SJsecondsectionCell *cell3 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        if (self.hotVideoArray.count) {
            cell3.model = self.hotVideoArray[indexPath.row];
        }
        
        return cell3;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake((SJScreenW-40)/3, 75);
    } else if (indexPath.section == 1) {
        return CGSizeMake((self.view.frame.size.width-30)/2, 145);
    } else {
        return CGSizeMake((self.view.frame.size.width-30)/2, 145);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(0, 10, 0, 10);
    } else {
        return UIEdgeInsetsMake(5, 10, 5, 10);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            [self.collectionView reloadData];
        } else if (indexPath.item == 1) {
            SJRecommendBookViewController *recommendBookVC = [[SJRecommendBookViewController alloc] init];
            [self.navigationController pushViewController:recommendBookVC animated:YES];
        } else {
            [MBHUDHelper showWarningWithText:@"此功能待开发！"];
        }
    } else if (indexPath.section == 1) {
        SJVideoViewController *video = [[SJVideoViewController alloc]init];
        SJSchoolVideoModel *model = self.newVideoArray[indexPath.row];
        video.course_id = model.course_id;
        
        [self.navigationController pushViewController:video animated:YES];
    } else {
        SJVideoViewController *video =[[SJVideoViewController alloc]init];
        SJSchoolVideoModel *model = self.hotVideoArray[indexPath.row];
        video.course_id = model.course_id;
        
        [self.navigationController pushViewController:video animated:YES];
    }
}

//设置每个分组头的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(0, 0);
    } else {
        return CGSizeMake(0, 50);
    }
}
//设置没组的headview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SJCollectionHeadview *headvc =[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head" forIndexPath:indexPath];
    headvc.delegate = self;
    if (indexPath.section == 1) {
        headvc.lable.text = @"最新视频";
        headvc.Morebtn.tag = 1234;
    } else {
        headvc.lable.text = @"最热视频";
        headvc.Morebtn.tag = 1235;
    }
    
    return headvc;
}
#pragma mark  SJCollectionHeadviewdelegate
- (void)btnclick:(UIButton *)sender {
    if (sender.tag == 1234) {
        //更多最新视频
        MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
        morevc.navigationItem.title = @"最新视频";
        [self.navigationController pushViewController:morevc animated:YES];
    } else {
        //更多最热视频
        MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
        morevc.navigationItem.title = @"最热视频";
        [self.navigationController pushViewController:morevc animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadVideoData];
    }
}

@end

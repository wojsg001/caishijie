//
//  SJschoolViewcontroller.m
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJSchoolViewcontroller.h"
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
#import "SJVideoPayViewController.h"
#import "SJLoginViewController.h"
#import "SJUserInfo.h"

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
    self.navigationItem.title = @"公开课";
    self.isNetwork = YES;
    [self initsubviews];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshNetwork];
    [self loadVideoData];
}

- (void)initsubviews {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH - kTabbarHeight - kStatusBarHeight - kStatusBarHeight) collectionViewLayout:layout];
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
        return 2;
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
//            cell1.headimage.image = [UIImage imageNamed:@"school_nav_icon3"];
//            cell1.namelable.text = @"原创类";
        }
        
        return cell1;
    } else if (indexPath.section == 1) {
        SJsecondsectionCell *cell2 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        if (self.newVideoArray.count) {
            cell2.model = self.newVideoArray[indexPath.row];
            WS(weakSelf);
            cell2.clickedPayButtonBlock = ^() {
                [weakSelf payReferenceWith:self.newVideoArray[indexPath.row]];
            };
            
            cell2.clickedFreeWatchButtonBlock = ^(){
                [weakSelf clickWatchReferenceWith:indexPath];
            };
            
            //显示是否已购买 0 免费 1 收费 2 已购买
            switch ([cell2.model.pay integerValue]) {
                case 0:
                    [cell2.priceLabel setText:@""];
                    cell2.freeButton.hidden = YES;
                    cell2.buyButton.hidden = YES;
                    break;
                case 1:
                    [cell2.priceLabel setText:[NSString stringWithFormat:@"%@元",@(cell2.model.course_price.floatValue)]];
                    cell2.freeButton.hidden = NO;
                    cell2.buyButton.hidden = NO;
                    break;
                case 2:
                    [cell2.priceLabel setText:@"已购买"];
                    cell2.freeButton.hidden = YES;
                    cell2.buyButton.hidden = YES;
                    break;
                default:
                    break;
            }
        }
    
        return cell2;
    } else {
        SJsecondsectionCell *cell3 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        if (self.hotVideoArray.count) {
            cell3.model = self.hotVideoArray[indexPath.row];
            WS(weakSelf);
            cell3.clickedPayButtonBlock = ^() {
                [weakSelf payReferenceWith:self.hotVideoArray[indexPath.row]];
            };
            cell3.clickedFreeWatchButtonBlock = ^(){
                [weakSelf clickWatchReferenceWith:indexPath];
            };
        }
        
        //显示是否已购买 0 免费 1 收费 0 已购买
        switch ([cell3.model.pay integerValue]) {
            case 0:
                [cell3.priceLabel setText:@""];
                cell3.freeButton.hidden = YES;
                cell3.buyButton.hidden = YES;
                break;
            case 1:
                [cell3.priceLabel setText:[NSString stringWithFormat:@"%@元",@(cell3.model.course_price.floatValue)]];
                cell3.freeButton.hidden = NO;
                cell3.buyButton.hidden = NO;
                break;
            case 2:
                [cell3.priceLabel setText:@"已购买"];
                cell3.freeButton.hidden = YES;
                cell3.buyButton.hidden = YES;
                break;
            default:
                break;
        }
        
        return cell3;
    }
}


- (void)payReferenceWith:(SJSchoolVideoModel *)referencemodel {
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        //        SJGiftModel *model = [[SJGiftModel alloc] init];
        //        model.gift_id = referencemodel.reference_id;
        //        model.gift_name = @"内参";
        //        model.price = referencemodel.price;
        //        [SJPayView showSJPayViewWithGiftModel:model targetid:referencemodel.user_id itemtype:@"20"];
        SJVideoPayViewController *payVC = [[SJVideoPayViewController alloc] init];
        payVC.model = referencemodel;
        [self.navigationController pushViewController:payVC animated:YES];
    } else {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

- (void)clickWatchReferenceWith:(NSIndexPath *)indexPath{
    SJVideoViewController *video = [[SJVideoViewController alloc] init];
    if((indexPath.section == 1)){
        SJSchoolVideoModel *model = self.newVideoArray[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
    }
    else if(indexPath.section == 2){
        SJSchoolVideoModel *model = self.hotVideoArray[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
    }
    
    [self.navigationController pushViewController:video animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake((SJScreenW-40)/2, 75);
    } else if (indexPath.section == 1) {
        return CGSizeMake((self.view.frame.size.width-30), 145);
    } else {
        return CGSizeMake((self.view.frame.size.width-30), 145);
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
            //[MBHUDHelper showWarningWithText:@"此功能待开发！"];
            //[self.collectionView reloadData];
            
            //更多
            MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
            morevc.navigationItem.title = @"课程视频";
            [self.navigationController pushViewController:morevc animated:YES];
        } else if (indexPath.item == 1) {
            SJRecommendBookViewController *recommendBookVC = [[SJRecommendBookViewController alloc] init];
            [self.navigationController pushViewController:recommendBookVC animated:YES];
        } else {
            //[MBHUDHelper showWarningWithText:@"此功能待开发！"];
            //更多收费课程
//            MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
//            morevc.navigationItem.title = @"原创类";
//            [self.navigationController pushViewController:morevc animated:YES];
        }
    } else if (indexPath.section == 1) {
        SJVideoViewController *video = [[SJVideoViewController alloc]init];
        SJSchoolVideoModel *model = self.newVideoArray[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
        [self.navigationController pushViewController:video animated:YES];
    } else {
        SJVideoViewController *video =[[SJVideoViewController alloc]init];
        SJSchoolVideoModel *model = self.hotVideoArray[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
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
//设置每组的headview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SJCollectionHeadview *headvc =[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head" forIndexPath:indexPath];
    headvc.delegate = self;
    if (indexPath.section == 1) {
        headvc.lable.text = @"最新课程";
        headvc.Morebtn.tag = 1234;
    } else {
        headvc.lable.text = @"最热课程";
        headvc.Morebtn.tag = 1235;
    }
    
    return headvc;
}
#pragma mark  SJCollectionHeadviewdelegate
- (void)btnclick:(UIButton *)sender {
    if (sender.tag == 1234) {
        //更多免费课程
        MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
        morevc.navigationItem.title = @"最新课程";
        [self.navigationController pushViewController:morevc animated:YES];
    } else {
        //更多收费课程
        MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
        morevc.navigationItem.title = @"最热课程";
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

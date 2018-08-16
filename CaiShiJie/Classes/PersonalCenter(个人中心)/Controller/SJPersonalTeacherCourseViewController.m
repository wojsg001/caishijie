//
//  SJPersonalTeacherCourseViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJPersonalTeacherCourseViewController.h"
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

@interface SJPersonalTeacherCourseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SJCollectionHeadviewdelegate,SJNoWifiViewDelegate>
{
    NSInteger i; // 分页
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *VideoArrayFree;
@property (nonatomic, strong) NSMutableArray *VideoArrayPay;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJPersonalTeacherCourseViewController

- (NSMutableArray *)VideoArrayFree {
    if (_VideoArrayFree == nil) {
        _VideoArrayFree = [NSMutableArray array];
    }
    return _VideoArrayFree;
}

- (NSMutableArray *)VideoArrayPay {
    if (_VideoArrayPay == nil) {
        _VideoArrayPay = [NSMutableArray array];
    }
    return _VideoArrayPay;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"精品课";
    self.isNetwork = YES;
    [self initsubviews];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self refreshNetwork];
    [self loadVideoData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
    [_collectionView registerNib:[UINib nibWithNibName:@"SJsecondsectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    //注册headview
    [_collectionView registerNib:[UINib nibWithNibName:@"SJCollectionHeadview" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
}

#pragma mark - 加载数据
- (void)loadVideoData {
    i = 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/teachercourse", HOST];
    NSDictionary *paramers = @{@"userid":self.target_id,@"pagesize":@"10",@"pageindex":@(i)};
    [SJhttptool GET:urlStr paramers:paramers success:^(id respose) {
        //SJLog(@"%@", respose);
        [self.collectionView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *VideoArrayFree = [SJSchoolVideoModel objectArrayWithKeyValuesArray:respose[@"data"][@"free"]];
            if (VideoArrayFree.count) {
                [self.VideoArrayFree removeAllObjects];
                [self.VideoArrayFree addObjectsFromArray:VideoArrayFree];
            }
            NSArray *hotVideoAray = [SJSchoolVideoModel objectArrayWithKeyValuesArray:respose[@"data"][@"pay"]];
            if (hotVideoAray.count) {
                [self.VideoArrayPay removeAllObjects];
                [self.VideoArrayPay addObjectsFromArray:hotVideoAray];
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
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.VideoArrayFree.count;
    } else {
        return  self.VideoArrayPay.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SJsecondsectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        if (self.VideoArrayFree.count) {
            cell.model = self.VideoArrayFree[indexPath.row];
            WS(weakSelf);
            cell.clickedPayButtonBlock = ^() {
                [weakSelf payReferenceWith:self.VideoArrayFree[indexPath.row]];
            };
            
            cell.clickedFreeWatchButtonBlock = ^(){
                [weakSelf clickWatchReferenceWith:indexPath];
            };
            
            //显示是否已购买 0 免费 1 收费 2 已购买
            switch ([cell.model.pay integerValue]) {
                case 0:
                    [cell.priceLabel setText:@""];
                    cell.freeButton.hidden = YES;
                    cell.buyButton.hidden = YES;
                    break;
                case 1:
                    [cell.priceLabel setText:[NSString stringWithFormat:@"%@元",@(cell.model.course_price.floatValue)]];
                    cell.freeButton.hidden = NO;
                    cell.buyButton.hidden = NO;
                    break;
                case 2:
                    [cell.priceLabel setText:@"已购买"];
                    cell.freeButton.hidden = YES;
                    cell.buyButton.hidden = YES;
                    break;
                default:
                    break;
            }
        }
    
        return cell;
    } else {
        SJsecondsectionCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        if (self.VideoArrayPay.count) {
            cell1.model = self.VideoArrayPay[indexPath.row];
            WS(weakSelf);
            cell1.clickedPayButtonBlock = ^() {
                [weakSelf payReferenceWith:self.VideoArrayPay[indexPath.row]];
            };
            cell1.clickedFreeWatchButtonBlock = ^(){
                [weakSelf clickWatchReferenceWith:indexPath];
            };
        }
        
        //显示是否已购买 0 免费 1 收费 0 已购买
        switch ([cell1.model.pay integerValue]) {
            case 0:
                [cell1.priceLabel setText:@""];
                cell1.freeButton.hidden = YES;
                cell1.buyButton.hidden = YES;
                break;
            case 1:
                [cell1.priceLabel setText:[NSString stringWithFormat:@"%@元",@(cell1.model.course_price.floatValue)]];
                cell1.freeButton.hidden = NO;
                cell1.buyButton.hidden = NO;
                break;
            case 2:
                [cell1.priceLabel setText:@"已购买"];
                cell1.freeButton.hidden = YES;
                cell1.buyButton.hidden = YES;
                break;
            default:
                break;
        }
        
        return cell1;
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
    if((indexPath.section == 0)){
        SJSchoolVideoModel *model = self.VideoArrayFree[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
    }
    else if(indexPath.section == 1){
        SJSchoolVideoModel *model = self.VideoArrayPay[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
    }
    
    [self.navigationController pushViewController:video animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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
        SJVideoViewController *video = [[SJVideoViewController alloc]init];
        SJSchoolVideoModel *model = self.VideoArrayFree[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
        [self.navigationController pushViewController:video animated:YES];
    } else {
        SJVideoViewController *video =[[SJVideoViewController alloc]init];
        SJSchoolVideoModel *model = self.VideoArrayPay[indexPath.row];
        video.course_id = model.course_id;
        video.schoolVideoModel = model;
        video.homepage = 1;
        [self.navigationController pushViewController:video animated:YES];
    }
}

//设置每个分组头的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(0, 50);
    } else {
        return CGSizeMake(0, 50);
    }
}
//设置每组的headview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SJCollectionHeadview *headvc =[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head" forIndexPath:indexPath];
    headvc.delegate = self;
    if (indexPath.section == 0) {
        headvc.lable.text = @"免费视频";
        headvc.Morebtn.tag = 1234;
    } else {
        headvc.lable.text = @"收费视频";
        headvc.Morebtn.tag = 1235;
    }
    
    return headvc;
}
#pragma mark  SJCollectionHeadviewdelegate
- (void)btnclick:(UIButton *)sender {
    if (sender.tag == 1234) {
        //更多免费视频
        MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
        morevc.navigationItem.title = @"免费视频";
        [self.navigationController pushViewController:morevc animated:YES];
    } else {
        //更多收费视频
        MorevideoViewController *morevc = [[MorevideoViewController alloc] init];
        morevc.navigationItem.title = @"收费视频";
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

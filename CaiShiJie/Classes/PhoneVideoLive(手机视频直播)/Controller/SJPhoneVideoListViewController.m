//
//  SJPhoneVideoListViewController.m
//  CaiShiJie
//
//  Created by user on 16/12/2.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPhoneVideoListViewController.h"
#import "SJhttptool.h"
#import "SJPhoneVideoListModel.h"
#import "MJExtension.h"
#import "SJWatchViewController.h"
#import "MJRefresh.h"

@interface SJPhoneVideoListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *voverImageView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *liveType;
@property (weak, nonatomic) IBOutlet UIButton *liveStatus;

@end

@implementation SJPhoneVideoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.liveStatus.layer.borderColor = [UIColor whiteColor].CGColor;
    self.liveStatus.layer.borderWidth = 0.5;
    self.liveStatus.layer.cornerRadius = 15/2;
    self.liveStatus.layer.masksToBounds = YES;
}

- (void)setModel:(SJPhoneVideoListModel *)model {
    _model = model;

    if ([_model.status isEqualToString:@"1"]) {
        [_voverImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@.jpg?t=%@", kVideo_imgURL, _model.hub, _model.video_id, [[NSDate date] stringDateWithYMDHM]]] placeholderImage:[UIImage imageNamed:@"live_list_placeholder"]];
    } else {
        [_voverImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHead_imgURL, _model.img]] placeholderImage:[UIImage imageNamed:@"live_list_placeholder"]];
    }
    
    [_titleButton setTitle:_model.title forState:UIControlStateNormal];
    _countLabel.text = [NSString stringWithFormat:@"%@人", _model.total_count];
    _nicknameLabel.text = _model.nickname;
}

@end

@interface SJPhoneVideoListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SJNoWifiViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJPhoneVideoListViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (instancetype)init {
    return [[UIStoryboard storyboardWithName:@"SJPhoneVideoStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PhoneVideoListVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"直播间";
    // 获取列表数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadListData];
    [self.collectionView addHeaderWithTarget:self action:@selector(loadListData)];
    self.collectionView.headerRefreshingText = @"正在刷新...";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)refresh {
    [self loadListData];
}

- (void)loadListData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live-video/videos", HOST];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.collectionView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        SJLog(@"%@", respose);
        NSArray *tmpArray = [SJPhoneVideoListModel objectArrayWithKeyValuesArray:respose];
        if (tmpArray.count) {
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:tmpArray];
            [self.collectionView reloadData];
        }
        
        if (!self.dataArray.count) {
            [SJNoDataView showNoDataViewToView:self.view];
        } else {
            [SJNoDataView hideNoDataViewFromView:self.view];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.collectionView headerEndRefreshing];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
        SJLog(@"%@", error);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJPhoneVideoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJPhoneVideoListCell" forIndexPath:indexPath];
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemW = (SJScreenW - 3) / 2;
    return CGSizeMake(itemW, itemW + 34);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SJPhoneVideoListModel *model = [self.dataArray objectAtIndex:indexPath.row];
    SJWatchViewController *watchVC = [[SJWatchViewController alloc] init];
    watchVC.targetid = model.user_id;
    [self.navigationController pushViewController:watchVC animated:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadListData];
}

@end

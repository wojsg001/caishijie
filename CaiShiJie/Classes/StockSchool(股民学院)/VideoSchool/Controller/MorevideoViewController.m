//
//  MorevideoViewController.m
//  shipin
//
//  Created by user on 16/4/19.
//  Copyright © 2018年 user. All rights reserved.
//

#import "MorevideoViewController.h"
#import "VideoCollectionViewCell.h"
#import "SJVideoViewController.h"
#import "SJhttptool.h"
#import "MBProgressHUD+MJ.h"
#import "MJRefresh.h"
#import "NSString+SJDate.h"
#import "NSDate+MJ.h"

@interface MorevideoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    int i; //最新分页
    int n; //最热分页
}

@property (nonatomic, strong) NSMutableArray *newvideo; //最新
@property (nonatomic, strong) NSMutableArray *hotarray; //最热

@end

@implementation MorevideoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (NSMutableArray *)newvideo {
    if (_newvideo == nil) {
        _newvideo = [NSMutableArray array];
    }
    return _newvideo;
}

- (NSMutableArray *)hotarray {
    if (_hotarray == nil) {
        _hotarray = [NSMutableArray array];
    }
    return _hotarray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.collectionview.delegate = self;
    self.collectionview.dataSource = self;
    self.collectionview.backgroundColor = [UIColor whiteColor];

    //注册cell
    [self.collectionview registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    if ([self.navigationItem.title isEqualToString:@"最热视频"]) {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadhotdata];
        [self.collectionview addHeaderWithTarget:self action:@selector(loadhotdata)];
        // 添加下拉获取更多数据
        [self.collectionview addFooterWithTarget:self action:@selector(loadmorehotdata)];
    } else {
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loaddata];
        // 添加下拉刷新
        [self.collectionview addHeaderWithTarget:self action:@selector(loaddata)];
        // 添加下拉获取更多数据
        [self.collectionview addFooterWithTarget:self action:@selector(loadMoredata)];
    }
    
    self.collectionview.headerRefreshingText = @"正在刷新...";
    self.collectionview.footerRefreshingText = @"正在加载...";
}

- (void)loaddata {
    i = 1;
    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"pageindex",@"10",@"pagesize",nil];
    NSString *url = [NSString stringWithFormat:@"%@/mobile/video/all",HOST];
    
    [SJhttptool GET:url paramers:paramers success:^(id respose) {
      //  SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            [self.newvideo removeAllObjects];
            
            NSDictionary *dic =respose[@"data"];
            NSArray *array =dic[@"course"];
            [_newvideo addObjectsFromArray:array];

            [self.collectionview reloadData];
            [self.collectionview headerEndRefreshing];
        } else {
            [self.collectionview headerEndRefreshing];
            [MBProgressHUD showError:@"未知错误，请求失败"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.collectionview headerEndRefreshing];
        [MBProgressHUD showError:@"网络不佳，请求失败"];
    }];
}

- (void)loadMoredata {
    i = i+1;
    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i],@"pageindex",@"10",@"pagesize",nil];
    NSString *url =[NSString stringWithFormat:@"%@/mobile/video/all",HOST];
    
    [SJhttptool GET:url paramers:paramers success:^(id respose) {
     //   SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSDictionary *dic =respose[@"data"];
            NSArray *array =dic[@"course"];
            
            [self.newvideo addObjectsFromArray:array];
            [self.collectionview reloadData];
            [self.collectionview footerEndRefreshing];
        }else{
             [self.collectionview footerEndRefreshing];
            [MBProgressHUD showError:@"未知错误，请求失败"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.collectionview footerEndRefreshing];
        [MBProgressHUD showError:@"网络不佳，请求失败"];
    }];
    
}

- (void)loadhotdata {
    n = 1;
    
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"pageindex",@"10",@"pagesize",nil];
    NSString *url =[NSString stringWithFormat:@"%@/mobile/video/hot",HOST];
    
    [SJhttptool GET:url paramers:paramers success:^(id respose) {
        //  SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            [self.hotarray removeAllObjects];
            
            NSDictionary *dic =respose[@"data"];
            NSArray *array =dic[@"course"];
            [_hotarray addObjectsFromArray:array];
            
            [self.collectionview reloadData];
            [self.collectionview headerEndRefreshing];
        } else {
            [self.collectionview headerEndRefreshing];
            [MBProgressHUD showError:@"未知错误，请求失败"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.collectionview headerEndRefreshing];
        [MBProgressHUD showError:@"网络不佳，请求失败"];
    }];
}

- (void)loadmorehotdata {
   n = n+1;
    
    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:n],@"pageindex",@"10",@"pagesize",nil];
    NSString *url = [NSString stringWithFormat:@"%@/mobile/video/hot",HOST];
    
    [SJhttptool GET:url paramers:paramers success:^(id respose) {
        //   SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSDictionary *dic = respose[@"data"];
            NSArray *array = dic[@"course"];
            
            [self.hotarray addObjectsFromArray:array];
            [self.collectionview reloadData];
            [self.collectionview footerEndRefreshing];
        } else {
            [self.collectionview footerEndRefreshing];
            [MBProgressHUD showError:@"未知错误，请求失败"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.collectionview footerEndRefreshing];
        [MBProgressHUD showError:@"网络不佳，请求失败"];
    }];
}

#pragma markcollectiondeleget
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.navigationItem.title isEqualToString:@"最热视频"]) {
        return _hotarray.count;
    } else {
        return _newvideo.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.navigationItem.title isEqualToString:@"最热视频"]) {
        VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        NSDictionary *dict = _hotarray[indexPath.row];
        
        cell.namelable.text = dict[@"nickname"];
        NSString *str = [NSString stringWithFormat:@"%@",dict[@"created_at"]];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[str intValue]];
        NSString *datestr = [NSString dateWithDate:date];
        cell.creat_at.text = datestr;
        
        [cell.img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,dict[@"img"]]] placeholderImage:[UIImage imageNamed:@"live_img-1"]];
        cell.courselable.text=dict[@"course_name"];

        return cell;
    } else {
        VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        NSDictionary *dict = _newvideo[indexPath.row];
        
        cell.namelable.text = dict[@"nickname"];
        NSString *str = [NSString stringWithFormat:@"%@",dict[@"created_at"]];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[str intValue]];
        NSString *datestr = [NSString dateWithDate:date];
        cell.creat_at.text = datestr;
        
        [cell.img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,dict[@"img"]]] placeholderImage:[UIImage imageNamed:@"live_img-1"]];
        cell.courselable.text=dict[@"course_name"];

        return cell;
    }
}

//返回每个分组的头高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 10);
}
//返回每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.frame.size.width-10*3)/2, 145);
}
//设值每个cell的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,10, 0, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     if ([self.navigationItem.title isEqualToString:@"最热视频"]) {
         SJVideoViewController *videos = [[SJVideoViewController alloc] init];
         NSDictionary *Dic = _hotarray[indexPath.row];
         NSString *courseid = Dic[@"course_id"];
         videos.course_id = courseid;
         [self.navigationController pushViewController:videos animated:YES];
     } else {
        SJVideoViewController *videos = [[SJVideoViewController alloc] init];
        NSDictionary *Dic = _newvideo[indexPath.row];
        NSString *courseid = Dic[@"course_id"];
        videos.course_id = courseid;
        [self.navigationController pushViewController:videos animated:YES];
     }
}

@end

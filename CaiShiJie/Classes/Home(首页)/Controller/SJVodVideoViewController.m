//
//  SJVideoViewController.m
//  CaiShiJie
//
//  Created by user on 18/7/21.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJVodVideoViewController.h"
#import "SJVodVideoSectionOneCell.h"
#import "SJProgramVideoSectionCell.h"
#import "SJBookDetailFootView.h"
#import "SJVodVideoInfoModel.h"
#import "SJProgramVideoInfoModel.h"
#import "SJVodVideoInfoListModel.h"
#import "SJProgramVideoInfoListModel.h"
#import "MJExtension.h"
#import "SJhttptool.h"
#import "SJMyLiveViewController.h"
#import "SJComposeViewController.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"
#import "SJToken.h"
#import "SJNetManager.h"
#import "XHPlayer.h"
#import "SJFullViewController.h"
#import "SJRecommendVideoModel.h"

@interface SJVodVideoViewController ()<UITableViewDataSource,UITableViewDelegate,SJBookDetailFootViewDelegate,UIAlertViewDelegate>
{
    int currentPage;
    int allPage;
    NSInteger curSelIndex;
}

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *programTableView;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) SJBookDetailFootView *tableViewFootView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSMutableArray *programDataList;
@property (nonatomic, strong) SJVodVideoInfoModel *vodVideoInfoModel;
@property (nonatomic, strong) SJProgramVideoInfoModel *programVideoInfoModel;
@property (nonatomic, strong) XHPlayer *player;
@property (nonatomic, strong) SJFullViewController *fullVC;

@end

@implementation SJVodVideoViewController

- (XHPlayer *)player {
    if (!_player) {
        _player = [[XHPlayer alloc] init];
        _player.mediaPath = nil;
        [self.playerView addSubview:_player];
        self.player.firstSuperView = self.playerView;
        WS(weakSelf);
        [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_equalTo(weakSelf.playerView);
        }];
        
        self.player.isFullScreenBlock = ^(BOOL isFull) {
            if (isFull) {
                SJLog(@"是全屏");
                [weakSelf.fullVC dismissViewControllerAnimated:NO completion:^{
                    weakSelf.player.playerView.bottomView.fullScreenButton.selected = NO;
                    weakSelf.player.isFullScreen = NO;
                    [weakSelf.player removeFromSuperview];
                    [weakSelf.playerView addSubview:weakSelf.player];
                    [weakSelf.player mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.left.bottom.right.mas_equalTo(weakSelf.playerView);
                    }];
                }];
                
            } else {
                SJLog(@"不是全屏");
                weakSelf.player.playerView.bottomView.fullScreenButton.selected = YES;
                weakSelf.player.isFullScreen = YES;
                [weakSelf.player removeFromSuperview];
                
                weakSelf.fullVC = [[SJFullViewController alloc] init];
                [weakSelf.fullVC.view addSubview:weakSelf.player];
                
                [weakSelf.player mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
                }];
                
                [weakSelf presentViewController:weakSelf.fullVC animated:NO completion:nil];
            }
        };
        
        self.player.clickBackButtonBlock = ^() {
            // 不是全屏时点击返回按钮
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _player;
}

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)programDataList {
    if (_programDataList == nil) {
        _programDataList = [NSMutableArray array];
    }
    return _programDataList;
}

- (SJBookDetailFootView *)tableViewFootView
{
    if (_tableViewFootView == nil)
    {
        _tableViewFootView = [[SJBookDetailFootView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 60)];
        _tableViewFootView.delegate = self;
    }
    return _tableViewFootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self initData];
    [self setUpChildViews];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"5"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)initData {
    currentPage = 1;
    allPage = 1;
}

- (void)setUpChildViews {
    WS(weakSelf);
    self.playerView = [[UIView alloc] init];
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerView];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"回看",@"节目单",nil];
    //初始化UISegmentedControl
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    [self.view addSubview:self.segmentedControl];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    self.programTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.programTableView.delegate = self;
    self.programTableView.dataSource = self;
    self.programTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.programTableView];
    

    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.view);
        make.height.mas_equalTo(SJScreenW * 11/16);
    }];
    self.segmentedControl.backgroundColor = [UIColor redColor];
    
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.playerView.mas_bottom).offset(0);
        make.height.mas_equalTo(SJScreenW * 1/8);
    }];
    
    // 设置分段选择控件
    [self setUpSegmentedControl];

    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.segmentedControl.mas_bottom).offset(0);
    }];
    
    [self.programTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.segmentedControl.mas_bottom).offset(0);
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SJVodVideoSectionOneCell" bundle:nil] forCellReuseIdentifier:@"SJVodVideoSectionOneCell"];
    
    [self.programTableView registerNib:[UINib nibWithNibName:@"SJProgramVideoSectionCell" bundle:nil] forCellReuseIdentifier:@"SJProgramVideoSectionCell"];
    
    self.tableView.tableFooterView = self.tableViewFootView;
    self.programTableView.tableFooterView = nil;
}

// 设置分段选择控件
- (void)setUpSegmentedControl {
    
    // 设置边框
    self.segmentedControl.layer.borderColor = RGB(247, 100, 8).CGColor;
    self.segmentedControl.layer.borderWidth = 1.0f;
    // 设置圆角
    self.segmentedControl.layer.cornerRadius = 5.0;
    self.segmentedControl.layer.masksToBounds = YES;
    // 背景色
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    // 选中色
    self.segmentedControl.tintColor = RGB(247, 100, 8);
    // 设置默认状态字体大小和颜色
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    attributes[NSForegroundColorAttributeName] = RGB(247, 100, 8);
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    // 设置选择状态时的大小和颜色
    attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateSelected];
    
    // 设置在点击后是否恢复原样
    self.segmentedControl.momentary = NO;
    // 默认选中第0个
    self.segmentedControl.selectedSegmentIndex = 0;
    curSelIndex = 0;
    self.programTableView.hidden = YES;
    
    [self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
 
}


- (void)segmentAction:(UISegmentedControl *)seg {
    curSelIndex = seg.selectedSegmentIndex;
    switch (curSelIndex) {
        case 0:
        {
            //回看
            [MBProgressHUD showMessage:@"加载中..." toView:self.view];
            [self loadVideoChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"5"];
            self.tableView.hidden = NO;
            self.programTableView.hidden = YES;
        }
            break;
        case 1:
        {
            //节目单
            [MBProgressHUD showMessage:@"加载中..." toView:self.view];
            [self loadProgramData];
            self.tableView.hidden = YES;
            self.programTableView.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - 加载数据
- (void)loadVideoChapterDataWith:(NSString *)pageindex and:(NSString *)pagesize {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/playback/index",HOST];
    NSDictionary *dic = @{@"pageindex":pageindex,@"pagesize":pagesize};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            self.vodVideoInfoModel = [SJVodVideoInfoModel objectWithKeyValues:respose[@"data"][@"playback"]];
            self.vodVideoInfoModel.count = [NSString stringWithFormat:@"%@", respose[@"data"][@"playback"][@"count"]];
            NSArray *tmpArr = [SJVodVideoInfoListModel objectArrayWithKeyValuesArray:respose[@"data"][@"playback"][@"data"]];
            if (tmpArr.count) {
                [self.dataList removeAllObjects];
                [self.dataList addObjectsFromArray:tmpArr];
            }
            
            int count = [respose[@"data"][@"count"] intValue];
            if (count%10 == 0) {
                allPage = count/10;
            } else {
                allPage = count/10 + 1;
            }
            
            [self.tableView reloadData];
            // 给tableFootView界面赋值
            self.tableViewFootView.currentPageLabel.text = [NSString stringWithFormat:@"第%i页",currentPage];
            self.tableViewFootView.allPageLabel.text = [NSString stringWithFormat:@"共%i页",allPage];
            
            if (self.recommendVideoModel == nil && (self.vod_id == nil || [self.vod_id isEqualToString:@"0"])) {
                // 初始化播放地址
                [self initURL];
            } else if (self.recommendVideoModel != nil) {
                self.player.mediaPath = self.recommendVideoModel.url;
                self.player.title = self.recommendVideoModel.title;
                for (SJVodVideoInfoListModel *model in self.dataList) {
                    if ([model.url isEqualToString:self.recommendVideoModel.url]) {
                        NSIndexPath *selIndexPath = [NSIndexPath indexPathForRow:[self.dataList indexOfObject:model] inSection:1];
                        [self.tableView selectRowAtIndexPath:selIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                        break;
                    }
                }
            } else {
                // 通过vod_id获取视频地址
                [self loadSelectedVideoURL];
                for (SJVodVideoInfoListModel *model in self.dataList) {
                    if ([model.item_id isEqualToString:self.vod_id]) {
                        NSIndexPath *selIndexPath = [NSIndexPath indexPathForRow:[self.dataList indexOfObject:model] inSection:1];
                        [self.tableView selectRowAtIndexPath:selIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                        break;
                    }
                }
            }
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"视频课程不存在!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 1001;
            [alert show];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)loadProgramData{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/program/index?",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%i",currentPage],@"pagesize":@"5"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            self.programVideoInfoModel = [SJProgramVideoInfoModel objectWithKeyValues:respose[@"data"][@"program"]];
            self.programVideoInfoModel.total = [NSString stringWithFormat:@"%@", respose[@"data"][@"program"][@"total"]];
            NSArray *tmpArr = [SJProgramVideoInfoListModel objectArrayWithKeyValuesArray:respose[@"data"][@"program"][@"data"]];
            if (tmpArr.count) {
                [self.programDataList removeAllObjects];
                [self.programDataList addObjectsFromArray:tmpArr];
            }
            
            int count = [respose[@"data"][@"program"][@"total"] intValue];
            if (count%10 == 0) {
                allPage = count/10;
            } else {
                allPage = count/10 + 1;
            }
            
            [self.programTableView reloadData];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)initURL {
    if (self.player.mediaPath == nil && self.dataList.count) {
        for (SJVodVideoInfoListModel *model in self.dataList) {
            if ([model.item_type isEqualToString:@"1"]) {
                self.player.mediaPath = model.url;
                self.player.title = model.title;
                NSIndexPath *selIndexPath = [NSIndexPath indexPathForRow:[self.dataList indexOfObject:model] inSection:1];
                [self.tableView selectRowAtIndexPath:selIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                break;
            }
        }
    }
}

- (void)loadSelectedVideoURL {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/video/detail?itemid=%@",HOST , self.vod_id];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        SJLog(@"%@", respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[respose[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            self.player.mediaPath = dic[@"url"];
            self.player.title = @"";
        } else {
            [MBHUDHelper showWarningWithText:@"获取视频地址失败"];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 1;
//    }
    if(curSelIndex == 0){
        return self.dataList.count;
    }
    else if (curSelIndex == 1){
        return self.programDataList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        SJProgramVideoSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJProgramVideoSectionCell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.model = self.videoInfoModel;
//        WS(weakSelf);
//        cell.allBtnClickEventBlock = ^(NSInteger index) {
//
//            switch (index) {
//                case 101:
//                {
//                    if (weakSelf.player) {
//                        [weakSelf.player pause];
//                    }
//
//                    SJLog(@"问股");
//                    SJComposeViewController *composeVC = [[SJComposeViewController alloc] init];
//                    composeVC.title = [NSString stringWithFormat:@"向「%@」提问", weakSelf.videoInfoModel.nickname];;
//                    composeVC.targetid = weakSelf.videoInfoModel.user_id;
//                    composeVC.type = @"0";
//
//                    [weakSelf.navigationController pushViewController:composeVC animated:YES];
//                }
//                    break;
//                case 102:
//                {
//                    SJLog(@"关注");
//                    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
//                    {
//                        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
//
//                        [weakSelf.navigationController pushViewController:loginVC animated:YES];
//
//                        return;
//                    }
//
//                    SJToken *instance = [SJToken sharedToken];
//                    [[SJNetManager sharedNetManager] addAttentionWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:weakSelf.videoInfoModel.user_id withSuccessBlock:^(NSDictionary *dict) {
//                        if ([dict[@"status"] isEqual:@"1"]) {
//                            // 提示用户关注成功
//                            [MBProgressHUD showSuccess:@"关注成功"];
//                        } else {
//                            [MBHUDHelper showWarningWithText:dict[@"data"]];
//                        }
//                    } andFailBlock:^(NSError *error) {
//                        [MBHUDHelper showWarningWithText:error.localizedDescription];
//                    }];
//
//                }
//                    break;
//                case 103:
//                {
//                    if (weakSelf.player) {
//                        [weakSelf.player pause];
//                    }
//                    SJLog(@"视频室");
////                    SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
////                    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
////                    myLiveVC.user_id = [d valueForKey:kUserid];
////                    myLiveVC.target_id = weakSelf.videoInfoModel.user_id;
////
////                    [weakSelf.navigationController pushViewController:myLiveVC animated:YES];
//                }
//                    break;
//
//                default:
//                    break;
//            }
//        };
//
//        return cell;
//    }
    if (curSelIndex == 0) {
        SJVodVideoSectionOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJVodVideoSectionOneCell"];
        if (!cell) {
            cell = [[SJVodVideoSectionOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SJVodVideoSectionOneCell"];
        }
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        SJVodVideoInfoListModel *model = self.dataList[indexPath.row];
        cell.model = model;
        cell.sortLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        cell.titleLabel = model.title;
        return cell;
    }
    else if (curSelIndex == 1){
        SJProgramVideoSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJProgramVideoSectionCell"];
        if (!cell) {
            cell = [[SJProgramVideoSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SJProgramVideoSectionCell"];
        }
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        SJProgramVideoInfoModel *model = self.programDataList[indexPath.row];
        cell.model = model;
        return cell;
    }


    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return 140;
//    }
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (section == 0) {
//        return 10;
//    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (curSelIndex == 0){
        SJVodVideoInfoListModel *model = self.dataList[indexPath.row];
            // 是视频
            self.player.mediaPath = model.url;
            self.player.title = model.title;
    }
    else if(curSelIndex == 1){
        return;
    }
}

#pragma mark - SJBookDetailFootViewDelegate
- (void)firstPageBtnClickDown {
    if (currentPage == 1)
    {
        [MBHUDHelper showWarningWithText:@"已至首页"];
        return;
    }
    
    currentPage = 1;
    [self.tableViewFootView.firstPageBtn setImage:[UIImage imageNamed:@"page_icon1_n"] forState:UIControlStateNormal];
    [self.tableViewFootView.beforePageBtn setImage:[UIImage imageNamed:@"page_icon2_n"] forState:UIControlStateNormal];
    [self.tableViewFootView.nextPageBtn setImage:[UIImage imageNamed:@"page_icon3_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.lastPageBtn setImage:[UIImage imageNamed:@"page_icon4_h"] forState:UIControlStateNormal];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10"];
}

- (void)beforePageBtnClickDown {
    currentPage--;
    if (currentPage < 1)
    {
        currentPage = 1;
        return;
    }
    [self.tableViewFootView.firstPageBtn setImage:[UIImage imageNamed:@"page_icon1_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.beforePageBtn setImage:[UIImage imageNamed:@"page_icon2_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.nextPageBtn setImage:[UIImage imageNamed:@"page_icon3_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.lastPageBtn setImage:[UIImage imageNamed:@"page_icon4_h"] forState:UIControlStateNormal];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10"];
    
    if (currentPage == 1)
    {
        [MBHUDHelper showWarningWithText:@"已至首页"];
        [self.tableViewFootView.firstPageBtn setImage:[UIImage imageNamed:@"page_icon1_n"] forState:UIControlStateNormal];
        [self.tableViewFootView.beforePageBtn setImage:[UIImage imageNamed:@"page_icon2_n"] forState:UIControlStateNormal];
        [self.tableViewFootView.nextPageBtn setImage:[UIImage imageNamed:@"page_icon3_h"] forState:UIControlStateNormal];
        [self.tableViewFootView.lastPageBtn setImage:[UIImage imageNamed:@"page_icon4_h"] forState:UIControlStateNormal];
        
        return;
    }
}

- (void)nextPageBtnClickDown {
    currentPage++;
    if (currentPage > allPage)
    {
        currentPage = allPage;
        return;
    }
    [self.tableViewFootView.firstPageBtn setImage:[UIImage imageNamed:@"page_icon1_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.beforePageBtn setImage:[UIImage imageNamed:@"page_icon2_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.nextPageBtn setImage:[UIImage imageNamed:@"page_icon3_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.lastPageBtn setImage:[UIImage imageNamed:@"page_icon4_h"] forState:UIControlStateNormal];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10"];
    
    if (currentPage == allPage)
    {
        [MBHUDHelper showWarningWithText:@"已至尾页"];
        [self.tableViewFootView.firstPageBtn setImage:[UIImage imageNamed:@"page_icon1_h"] forState:UIControlStateNormal];
        [self.tableViewFootView.beforePageBtn setImage:[UIImage imageNamed:@"page_icon2_h"] forState:UIControlStateNormal];
        [self.tableViewFootView.nextPageBtn setImage:[UIImage imageNamed:@"page_icon3_n"] forState:UIControlStateNormal];
        [self.tableViewFootView.lastPageBtn setImage:[UIImage imageNamed:@"page_icon4_n"] forState:UIControlStateNormal];
        return;
    }
}

- (void)lastPageBtnClickDown {
    if (currentPage == allPage)
    {
        [MBHUDHelper showWarningWithText:@"已至尾页"];
        return;
    }
    
    currentPage = allPage;
    [self.tableViewFootView.firstPageBtn setImage:[UIImage imageNamed:@"page_icon1_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.beforePageBtn setImage:[UIImage imageNamed:@"page_icon2_h"] forState:UIControlStateNormal];
    [self.tableViewFootView.nextPageBtn setImage:[UIImage imageNamed:@"page_icon3_n"] forState:UIControlStateNormal];
    [self.tableViewFootView.lastPageBtn setImage:[UIImage imageNamed:@"page_icon4_n"] forState:UIControlStateNormal];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadVideoChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10"];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        if (buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)dealloc {
    SJLog(@"SJVideoViewController dealloc");
    
    if (self.player) {
        [self.player close];
        self.player = nil;
    }
}

@end

//
//  SJHomeRecommendViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/12.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJHomeRecommendViewController.h"
#import "SJRecommendHeaderView.h"
#import "SJRecommendFooterView.h"
#import "SJHomeRecommendBlogCell.h"
#import "SJHomeRecommendLiveCell.h"
#import "SJIndexCollectionViewController.h"
//#import "SJRecommendStockCell.h" 去掉股票列表
#import "SJRecommendHotVideoOneCell.h"
#import "SJRecommendHotVideoTwoCell.h"
#import "SDCycleScrollView.h"
#import "SJhttptool.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "SJScrollViewImageModel.h"
#import "SJMyLiveViewController.h"
#import "KINWebBrowserViewController.h"
#import "SJBlogArticleListViewController.h"
#import "SJBlogArticleModel.h"
#import "SJLiveRoomModel.h"
#import "SJRecommendStockModel.h"
#import "SJRecommendVideoModel.h"
#import "SJLogDetailViewController.h"
#import "SJVideoViewController.h"
#import "SJStockDetailContentViewController.h"
#import "SJNewLiveRoomViewController.h"
#import "AFNetworking.h"
#import "SJHomeCustomButton.h"
#import "SJHomeLiveViewController.h"
#import "SJFindTeacherViewController.h"
#import "SJRankingsViewController.h"
#import "SJHomeQuestionViewController.h"
#import "SJNewBlogArticleViewController.h"
#import "SJsearchController.h"
//#import "SJHomeEliteTableViewCell.h"
#import "SJMasterTeacherCell.h"
#import "SJMasterTeacherCell.h"
#import "SJMasterTeacherModel.h"
#import "SJPersonalCenterViewController.h"
#import "SJVodVideoViewController.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"

@interface SJHomeRecommendViewController ()<UITableViewDataSource, UITableViewDelegate, SDCycleScrollViewDelegate, KINWebBrowserDelegate, SJNoWifiViewDelegate,SJMasterTeacherCellDelegate>
{
    BOOL _isClear;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) NSArray *imageModelArr;
@property (nonatomic, strong) NSMutableArray *recommendBlogArray;
@property (nonatomic, strong) NSArray *recommendLiveArray;
@property (nonatomic, strong) NSMutableArray *recommendStockArray;
@property (nonatomic, strong) NSMutableArray *recommendVideoArray;
@property (nonatomic, assign) BOOL isNetwork;
@property (nonatomic, weak) UIView *tableHeaderView;
@property (nonatomic, weak) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) SJIndexCollectionViewController *stockIndexVC;
@property (nonatomic, weak) UIView *navigationBar;
@property (nonatomic, weak) UIButton *searchButton;
@property (nonatomic, strong) NSArray *masterArray;
@end

@implementation SJHomeRecommendViewController

- (NSMutableArray *)recommendStockArray {
    if (!_recommendStockArray) {
        _recommendStockArray = [NSMutableArray array];
    }
    return _recommendStockArray;
}

- (NSMutableArray *)recommendVideoArray {
    if (_recommendVideoArray == nil) {
        _recommendVideoArray = [NSMutableArray array];
    }
    return _recommendVideoArray;
}

- (NSMutableArray *)recommendBlogArray
{
    if (_recommendBlogArray == nil) {
        _recommendBlogArray = [NSMutableArray array];
    }
    return _recommendBlogArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    self.isNetwork = YES; //默认有网
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUpSubviews];
    [self setUpTableViewHeadView];
    [self loadStockMarkHeadline];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadData];
    [self loadMasterTeacherData];
    // 下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self refreshNetwork];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMarketIndex:) name:KNotificationMarketIndex object:nil];
}

- (void)setUpSubviews {
    self.sectionArray = @[/*@{@"icon":@"index_tuijian_icon1",@"title":@"推荐股评"},*/ @{@"icon":@"index_tuijian_icon1",@"title":@"直播回顾"},
                          @{@"icon":@"index_mingshi_icon2",@"title":@"名师专栏"}, @{@"icon":@"index_tuijian_icon3",@"title":@"热门视频"}, /*@{@"icon":@"index_tuijian_icon4",@"title":@"热门股票"},*/@{@"icon":@"index_dakaquanicon4",@"title":@"股市头条"}, ];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH - kTabbarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    

    [_tableView registerNib:[UINib nibWithNibName:@"SJHomeRecommendLiveCell" bundle:nil] forCellReuseIdentifier:@"SJHomeRecommendLiveCell"];
//    [_tableView registerNib:[UINib nibWithNibName:@"SJRecommendStockCell" bundle:nil] forCellReuseIdentifier:@"SJRecommendStockCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"SJRecommendHotVideoOneCell" bundle:nil] forCellReuseIdentifier:@"SJRecommendHotVideoOneCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"SJRecommendHotVideoTwoCell" bundle:nil] forCellReuseIdentifier:@"SJRecommendHotVideoTwoCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"SJHomeRecommendBlogCell" bundle:nil] forCellReuseIdentifier:@"SJHomeRecommendBlogCell"];
//    [_tableView registerClass:[SJHomeEliteTableViewCell class] forCellReuseIdentifier:@"SJHomeEliteTableViewCell"];

    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 64)];
    self.navigationBar = navigationBar;
    navigationBar.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:0.0];
    _isClear = YES;
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1.0];
    [self.view addSubview:navigationBar];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(10, kStatusBarHeight + 10, SJScreenW - 20, 28)];
    self.searchButton = searchButton;
    searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [searchButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [searchButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [searchButton setBackgroundColor:[UIColor colorWithHexString:@"#ffffff" withAlpha:0.4]];
    [searchButton setImage:[UIImage imageNamed:@"index_account_soso"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"index_account_soso"] forState:UIControlStateHighlighted];
    [searchButton setTitle:@"搜索股票" forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // 改变图片颜色（图片需设置TemplateImage）
    searchButton.imageView.tintColor = [UIColor whiteColor];
    searchButton.layer.borderColor = [UIColor whiteColor].CGColor;
    searchButton.layer.borderWidth = 0.5;
    searchButton.layer.cornerRadius = 5.0;
    searchButton.layer.masksToBounds = YES;
    [navigationBar addSubview:searchButton];
    

}

- (void)searchButtonPressed:(UIButton *)button {
    SJsearchController *searchVC =[[SJsearchController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/home/index",HOST];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            // 滚动图数据
            self.imageModelArr = [SJScrollViewImageModel objectArrayWithKeyValuesArray:respose[@"data"][@"Advertising"]];
            NSMutableArray *imagesURLStrings = [NSMutableArray array];
            for (SJScrollViewImageModel *model in self.imageModelArr) {
                NSString *urlStr = [NSString stringWithFormat:@"%@/%@", kScroll_imgURL, model.img];
                [imagesURLStrings addObject:urlStr];
            }
            self.cycleScrollView.imageURLStringsGroup = imagesURLStrings;
//            // 博文数据
//            self.recommendBlogArray = [SJBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"ElectArticle"]];
            // 视频数据
            self.recommendLiveArray = [SJLiveRoomModel objectArrayWithKeyValuesArray:respose[@"data"][@"ElectLive"]];
//            // 股票数据
//            NSArray *stockArray = respose[@"data"][@"ElectStock"];
//            [self loadSinnaStock:stockArray];
            // 视频数据
            NSArray *videoArray = [SJRecommendVideoModel objectArrayWithKeyValuesArray:respose[@"data"][@"ElectVideo"]];
            if (videoArray.count) {
                NSMutableArray *tmpArrOne = [NSMutableArray array];
                for (int i = 0; i < videoArray.count; i++) {
                    SJRecommendVideoModel *model = videoArray[i];
                    [tmpArrOne addObject:model];
                    if (i >= 1) {
                        break;
                    }
                }
                
                [self.recommendVideoArray removeAllObjects];
                [self.recommendVideoArray addObject:tmpArrOne];
                for (SJRecommendVideoModel *model in videoArray) {
                    if (![tmpArrOne containsObject:model]) {
                        [self.recommendVideoArray addObject:model];
                    }
                }
            }
            [self.tableView reloadData];
        } else {
            [MBHUDHelper showWarningWithText:respose[@"data"]];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadSinnaStock:(NSArray *)array {
    NSMutableString *stockStr = [NSMutableString string];
    for (NSDictionary *tmpDic in array) {
        [stockStr appendString:@"s_"];
        [stockStr appendString:tmpDic[@"type"]];
        [stockStr appendString:tmpDic[@"code"]];
        [stockStr appendString:@","];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@", stockStr];
    //SJLog(@"%@", urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:encode];
        
        NSArray *matches = [self matcheInString:obj regularExpressionWithPattern:@"s_([a-z]{2})([0-9]{6})=\"(\\S{1,})\""];
        [self.recommendStockArray removeAllObjects];
        for (NSTextCheckingResult *match in matches) {
            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
            
            NSString *tmpStrOne = [obj substringWithRange:match.range];
            NSArray *tmpArrayOne = [tmpStrOne componentsSeparatedByString:@"="];
            
            NSString *tmpStrTwo = tmpArrayOne[1];
            tmpStrTwo = [tmpStrTwo stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *tmpArrayTwo = [tmpStrTwo componentsSeparatedByString:@","];
            tmpDic[@"name"] = tmpArrayTwo[0];
            tmpDic[@"currentPrice"] = tmpArrayTwo[1];
            tmpDic[@"zhangdie"] = tmpArrayTwo[3];
            
            NSString *tmpStrThree = tmpArrayOne[0];
            tmpStrThree = [tmpStrThree stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            tmpDic[@"code"] = [tmpStrThree substringWithRange:NSMakeRange(4, 6)];
            tmpDic[@"code2"] = [tmpStrThree substringWithRange:NSMakeRange(2, 8)];
            [self.recommendStockArray addObject:[SJRecommendStockModel objectWithKeyValues:tmpDic]];
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}


- (void)loadMasterTeacherData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/ranking/teacher",HOST];
    NSDictionary *dic = @{@"pagesize":@"8"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = respose[@"data"][@"teacher"];
            if (tmpArr.count) {
                self.masterArray = [SJMasterTeacherModel objectArrayWithKeyValuesArray:tmpArr];
 //               NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:0];//刷新
//                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}


- (NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern {
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:string options:0 range:range];
    return matches;
}

- (void)setUpTableViewHeadView {
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SJScreenW, 170) imageURLStringsGroup:@[@"index-banner"]];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.autoScrollTimeInterval = 3.0;
    cycleScrollView.infiniteLoop = YES;
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    cycleScrollView.placeholderImage = [UIImage imageNamed:@"index-banner"];
    

    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 257)];
    self.tableHeaderView = tableHeaderView;
    tableHeaderView.backgroundColor = RGB(245, 245, 248);
    [tableHeaderView addSubview:cycleScrollView];
    
    self.stockIndexVC = [[SJIndexCollectionViewController alloc] init];

    [self.stockIndexVC.view setFrame:CGRectMake(0, cycleScrollView.size.height, SJScreenW, tableHeaderView.size.height - cycleScrollView.size.height)];
    [tableHeaderView addSubview:self.stockIndexVC.view];

//    [self setupOneCustomButtonWithImage:[UIImage imageNamed:@"nav_icon1"] tag:0 title:@"推荐"];
//    [self setupOneCustomButtonWithImage:[UIImage imageNamed:@"nav_icon2"] tag:1 title:@"问答"];
//    [self setupOneCustomButtonWithImage:[UIImage imageNamed:@"nav_icon3"] tag:2 title:@"找老师"];
//    [self setupOneCustomButtonWithImage:[UIImage imageNamed:@"nav_icon4"] tag:3 title:@"股评"];
//    [self setupOneCustomButtonWithImage:[UIImage imageNamed:@"nav_icon5"] tag:4 title:@"排行榜"];

    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)setupOneCustomButtonWithImage:(UIImage *)image tag:(NSInteger)tag title:(NSString *)title {
    SJHomeCustomButton *button = [SJHomeCustomButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#737373" withAlpha:1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.tag = tag;
    [button addTarget:self action:@selector(customButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake((SJScreenW/5) * tag, 170, SJScreenW/5, 87);
    [self.tableHeaderView addSubview:button];
}

- (void)customButtonPressed:(UIButton *)button {
    switch (button.tag) {
        case 0: {
            // 股市视频
            SJHomeLiveViewController *liveVC = [[SJHomeLiveViewController alloc] init];
            liveVC.navigationItem.title = @"股市视频";
            [self.navigationController pushViewController:liveVC animated:YES];
        }
            break;
        case 1: {
            // 问答
            SJHomeQuestionViewController *questionVC = [[SJHomeQuestionViewController alloc] init];
            questionVC.navigationItem.title = @"问答";
            [self.navigationController pushViewController:questionVC animated:YES];
        }
            break;
        case 2: {
            // 找老师
            SJFindTeacherViewController *findTeacherVC = [[SJFindTeacherViewController alloc] init];
            findTeacherVC.navigationItem.title = @"找老师";
            [self.navigationController pushViewController:findTeacherVC animated:YES];
        }
            break;
        case 3: {
            // 股评
            SJNewBlogArticleViewController *blogArticleVC = [[SJNewBlogArticleViewController alloc] init];
            blogArticleVC.navigationItem.title = @"股评";
            [self.navigationController pushViewController:blogArticleVC animated:YES];
        }
            break;
        case 4: {
            // 排行榜
            SJRankingsViewController *rankVC = [[SJRankingsViewController alloc] init];
            rankVC.navigationItem.title = @"排行榜";
            [self.navigationController pushViewController:rankVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - SDCycleScrollViewDelegate 代理方法
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    SJLog(@"---点击了第%li张图片", (long)index);
    SJScrollViewImageModel *model = self.imageModelArr[index];
    
    if ([model.url integerValue] > 0) {
//        SJMyLiveViewController *liveVC = [[SJMyLiveViewController alloc] init];
//        liveVC.target_id = model.url;
//
//        [self.navigationController pushViewController:liveVC animated:YES];
    } else {
        KINWebBrowserViewController *webBrowserVC = [KINWebBrowserViewController webBrowser];
        [webBrowserVC setDelegate:self];
        [webBrowserVC loadURLString:model.url];
        webBrowserVC.tintColor = [UIColor whiteColor];
        
        [self.navigationController pushViewController:webBrowserVC animated:YES];
    }
}

#pragma mark - KINWebBrowserDelegate
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error {
    [MBHUDHelper showWarningWithText:@"加载失败！"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
        //return self.recommendBlogArray.count;
    } else if (section == 1) {
        return self.recommendLiveArray.count;
    } else if (section == 2) {
        return self.recommendVideoArray.count;
    } else if (section == 3) {
        return self.recommendBlogArray.count;
//        return self.recommendStockArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //直播回顾
        SJHomeRecommendLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHomeRecommendLiveCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.recommendLiveArray.count) {
            cell.model = self.recommendLiveArray[indexPath.row];
            
        }
        return cell;

    } else if (indexPath.section == 1) {
        //名师专栏
        SJMasterTeacherCell *cell = [SJMasterTeacherCell cellWithTableView:tableView];
        cell.delegate = self;
        if (!cell.array.count) {
            cell.array = self.masterArray;
        }
        
        return cell;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            SJRecommendHotVideoOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJRecommendHotVideoOneCell"];
            
            WS(weakSelf);
            if (self.recommendVideoArray.count) {
                id value = self.recommendVideoArray[indexPath.row];
                cell.array = value;
                cell.recommendHotVideoBlock = ^(NSInteger index){
                    
                    NSArray *tmpArr = weakSelf.recommendVideoArray[indexPath.row];
                    SJRecommendVideoModel *model;
                    switch (index) {
                        case 1001:
                            model = tmpArr[0];
                            break;
                        case 1002:
                            model = tmpArr[1];
                            break;
                            
                        default:
                            break;
                    }
                    
                    SJVideoViewController *videoVC =[[SJVideoViewController alloc]init];
                    videoVC.course_id = model.course_id
                    ;
                    videoVC.homepage = 0; //首页课程免费
                    videoVC.recommendVideoModel = model;
                    [weakSelf.navigationController pushViewController:videoVC animated:YES];
                };
            }
            
            return cell;
        } else {
            SJRecommendHotVideoTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJRecommendHotVideoTwoCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (self.recommendVideoArray.count) {
                id value = self.recommendVideoArray[indexPath.row];
                cell.model = value;
            }
            
            return cell;
        }
    } else if (indexPath.section == 3) {
//        SJRecommendStockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJRecommendStockCell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//        if (self.recommendStockArray.count) {
//            cell.model = self.recommendStockArray[indexPath.row];
//        }
        //股市头条
        SJHomeRecommendBlogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJHomeRecommendBlogCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.recommendBlogArray.count) {
            cell.model = self.recommendBlogArray[indexPath.row];
        }
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SJRecommendHeaderView *sectionHeader = [[NSBundle mainBundle] loadNibNamed:@"SJRecommendHeaderView" owner:nil options:nil].lastObject;
    NSDictionary *dic = self.sectionArray[section];
    sectionHeader.iconView.image = [UIImage imageNamed:dic[@"icon"]];
    sectionHeader.titleLabel.text = dic[@"title"];
    return sectionHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if (section == 3) {
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 55)];
//        footerView.backgroundColor = [UIColor whiteColor];
//        UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, footerView.frame.size.width - 20, footerView.frame.size.height - 20)];
//        [moreBtn setTitle:@"查看自选股..." forState:UIControlStateNormal];
//        [moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        moreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//        [moreBtn setBackgroundColor:RGB(217, 67, 50)];
//        moreBtn.tag = section + 101;
//        [moreBtn addTarget:self action:@selector(clickMoreBtnDown:) forControlEvents:UIControlEventTouchUpInside];
//        [footerView addSubview:moreBtn];
//
//        return footerView;
//    }
//
    SJRecommendFooterView *sectionFooter = [[NSBundle mainBundle] loadNibNamed:@"SJRecommendFooterView" owner:nil options:nil].lastObject;
    sectionFooter.moreBtn.tag = section + 101;
    [sectionFooter.moreBtn addTarget:self action:@selector(clickMoreBtnDown:) forControlEvents:UIControlEventTouchUpInside];

    if (section == 1 || section == 0){
        sectionFooter.hidden = YES;
    }
    
    return sectionFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 3) {
        return 0;
    }
    
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 200; //直播互动
    } else if (indexPath.section == 1) {
         return (SJScreenW - 20)/4 + 32; //名师专栏
    } else if (indexPath.section == 2) {
        //热门视频
        if (indexPath.row == 0) {
            return (SJScreenW - 30)/2 * 107/172 + 48;
        } else {
            return 80;
        }
    } else if (indexPath.section == 3) {
        //股市头条
        return 140;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
//        SJBlogArticleModel *model = self.recommendBlogArray[indexPath.row];
//        SJLogDetailViewController *logDetailVC = [[SJLogDetailViewController alloc] init];
//        logDetailVC.article_id = model.article_id;
//        [self.navigationController pushViewController:logDetailVC animated:YES];
        
//        SJLiveRoomModel *model = self.recommendLiveArray[indexPath.row];
//        if ([model.user_id isEqualToString:@"10412"]) {
//                        SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
//                        liveRoomVC.target_id = model.user_id;
//                        [self.navigationController pushViewController:liveRoomVC animated:YES];
//        } else {
//                        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//                        myLiveVC.user_id = [SJUserDefaults valueForKey:kUserid];
//                        myLiveVC.target_id = model.user_id;
//                        [self.navigationController pushViewController:myLiveVC animated:YES];
//        }
        
        SJVodVideoViewController *videoVC =[[SJVodVideoViewController alloc]init];
        NSArray *tmpArr = self.recommendVideoArray[indexPath.row];
        SJRecommendVideoModel *model = tmpArr[0];
        videoVC.course_id = model.course_id
        ;
        videoVC.recommendVideoModel = model;
        [self.navigationController pushViewController:videoVC animated:YES];
    } else if (indexPath.section == 1) {
//        SJLiveRoomModel *model = self.recommendLiveArray[indexPath.row];
//        if ([model.user_id isEqualToString:@"10412"]) {
//            SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
//            liveRoomVC.target_id = model.user_id;
//            [self.navigationController pushViewController:liveRoomVC animated:YES];
//        } else {
//            SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
//            myLiveVC.user_id = [SJUserDefaults valueForKey:kUserid];
//            myLiveVC.target_id = model.user_id;
//            [self.navigationController pushViewController:myLiveVC animated:YES];
//        }
    } else if (indexPath.section == 2) {
        if (indexPath.row != 0) {
            SJVideoViewController *videoVC =[[SJVideoViewController alloc]init];
            SJRecommendVideoModel *model = self.recommendVideoArray[indexPath.row];
            videoVC.course_id = model.course_id;
            videoVC.recommendVideoModel = model;
            [self.navigationController pushViewController:videoVC animated:YES];
        }
    } else if (indexPath.section == 3) {
        SJBlogArticleModel *model = self.recommendBlogArray[indexPath.row];
        SJLogDetailViewController *detailVC = [[SJLogDetailViewController alloc] initWithNibName:@"SJLogDetailViewController" bundle:nil];
        detailVC.article_id = model.article_id;
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - 更多按钮点击事件
- (void)clickMoreBtnDown:(UIButton *)sender {
    switch (sender.tag) {
        case 101:
        {
            SJBlogArticleListViewController *blogArticleListVC = [[SJBlogArticleListViewController alloc] init];
            blogArticleListVC.selectedIndex = 0;
            [self.navigationController pushViewController:blogArticleListVC animated:YES];
        }
            break;
        case 102:
        {
            SJHomeLiveViewController *liveVC = [[SJHomeLiveViewController alloc] init];
            liveVC.navigationItem.title = @"推荐";
            [self.navigationController pushViewController:liveVC animated:YES];
        }
            break;
        case 103:
        {
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];
        }
            break;
        case 104:
        {
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];
        }
            break;
            
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= 106) {
        if (_isClear) {
            [UIView animateWithDuration:0.2 animations:^{
                self.navigationBar.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1.0];
                [_searchButton setBackgroundColor:[UIColor colorWithHexString:@"#ffffff" withAlpha:0.0]];
            } completion:^(BOOL finished) {
                _isClear = NO;
            }];
        }
    } else {
        if (!_isClear) {
            [UIView animateWithDuration:0.2 animations:^{
                self.navigationBar.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:0.0];
                
                [_searchButton setBackgroundColor:[UIColor colorWithHexString:@"#ffffff" withAlpha:0.4]];
                
                UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
                statusBar.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1.0];
            } completion:^(BOOL finished) {
                _isClear = YES;
            }];
        }
    }
}

#pragma mark - SJMasterTeacherCellDelegate
- (void)masterTeacherCell:(SJMasterTeacherCell *)masterTeacherCell didSelectedwhichOne:(NSInteger)index {
    SJMasterTeacherModel *model = self.masterArray[index];
    //    if ([model.user_id isEqualToString:@"10412"]) {
    //        SJNewLiveRoomViewController *liveRoomVC = [[SJNewLiveRoomViewController alloc] init];
    //        liveRoomVC.target_id = model.user_id;
    //        [self.navigationController pushViewController:liveRoomVC animated:YES];
    //    } else {
    //        SJMyLiveViewController *myLiveVC = [[SJMyLiveViewController alloc] init];
    //        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    //        myLiveVC.user_id = [d valueForKey:kUserid];
    //        myLiveVC.target_id = model.user_id;
    //
    //        [self.navigationController pushViewController:myLiveVC animated:YES];
    //    }
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }else {
      SJPersonalCenterViewController *personalCenterVC = [[SJPersonalCenterViewController alloc] init];
      personalCenterVC.target_id = model.user_id;
      [self.navigationController pushViewController:personalCenterVC animated:YES];
    }
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadData];
    }
}

- (void)loadStockMarkHeadline
{
    NSInteger pageIndex = 1; //分页
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findbytype",HOST];
    NSDictionary *dic = @{@"pageindex":[NSString stringWithFormat:@"%li",(long)pageIndex],@"pagesize":@"10",@"type":@"1"};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArr = [SJBlogArticleModel objectArrayWithKeyValuesArray:respose[@"data"][@"article"]];
            if (tmpArr.count) {
                [self.recommendBlogArray removeAllObjects];
                [self.recommendBlogArray addObjectsFromArray:tmpArr];
            }
            
            if (!self.recommendBlogArray.count) {
                // 如果没有数据，显示提示页
                [SJNoDataView showNoDataViewToView:self.view];
            } else {
                [SJNoDataView hideNoDataViewFromView:self.view];
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@",error);
        [self.tableView headerEndRefreshing];
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - 接收加载互动的通知
- (void)gotoMarketIndex:(NSNotification *)n
{
    NSDictionary *dic = n.object;
    SJStockDetailContentViewController *stockDetailVC =[[SJStockDetailContentViewController alloc] init];
    stockDetailVC.code = dic[@"code"];
    stockDetailVC.name = dic[@"name"];
    stockDetailVC.type = dic[@"type"];
    [self.navigationController pushViewController:stockDetailVC animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
}

@end

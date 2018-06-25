//
//  SJNewLiveVideoListViewController.m
//  CaiShiJie
//
//  Created by user on 18/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNewLiveVideoListViewController.h"
#import "SJLiveVideoListCell.h"
#import "SJhttptool.h"
#import "SJNewLiewVideoListModel.h"
#import "MJExtension.h"
#import "SJVideoViewController.h"
#import "MJRefresh.h"

@interface SJNewLiveVideoListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *topToolBar;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *course_id;

@end

@implementation SJNewLiveVideoListViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildViews];
    [self loadVideoListData];
    [self.tableView addHeaderWithTarget:self action:@selector(loadVideoListData)];
    self.tableView.headerRefreshingText = @"正在刷新...";
}

- (void)setTotal_count:(NSString *)total_count {
    _total_count = total_count;
    self.praiseLabel.text = _total_count;
}

- (void)setupChildViews {
    WS(weakSelf);
    _topToolBar = [[UIView alloc] init];
    _topToolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topToolBar];
    [_topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(35);
    }];
    
    _moreButton = [[UIButton alloc] init];
    [_moreButton setTitle:@"查看更多>>" forState:UIControlStateNormal];
    [_moreButton setTitleColor:[UIColor colorWithHexString:@"#f76408" withAlpha:1] forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.topToolBar addSubview:_moreButton];
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.topToolBar.mas_left).offset(10);
        make.centerY.mas_equalTo(weakSelf.topToolBar);
    }];
    
    _praiseLabel = [[UILabel alloc] init];
    _praiseLabel.font = [UIFont systemFontOfSize:15];
    _praiseLabel.text = @"0";
    _praiseLabel.textColor = [UIColor colorWithHexString:@"#999999" withAlpha:1];
    [self.topToolBar addSubview:_praiseLabel];
    [_praiseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.topToolBar.mas_right).offset(-10);
        make.centerY.mas_equalTo(weakSelf.topToolBar);
    }];
    
    _praiseButton = [[UIButton alloc] init];
    [_praiseButton setImage:[UIImage imageNamed:@"new_todaylive_icon1"] forState:UIControlStateNormal];
    [self.topToolBar addSubview:_praiseButton];
    [_praiseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.praiseLabel.mas_left).offset(-5);
        make.centerY.mas_equalTo(weakSelf.topToolBar);
    }];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.view addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.topToolBar.mas_bottom).offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [_tableView registerNib:[UINib nibWithNibName:@"SJLiveVideoListCell" bundle:nil] forCellReuseIdentifier:@"SJLiveVideoListCell"];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.lineView.mas_bottom).offset(0);
    }];
}

- (void)moreButtonClicked:(UIButton *)button {
    SJVideoViewController *videoVC = [[SJVideoViewController alloc] init];
    videoVC.course_id = self.course_id;
    [self.navigationController pushViewController:videoVC animated:YES];
    if (self.skipToVideoCourseBlock) {
        self.skipToVideoCourseBlock();
    }
}

- (void)loadVideoListData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/today-programs?user_id=%@", HOST, self.target_id];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"直播列表%@", respose);
        if ([respose[@"status"] isEqualToString:@"1"]) {
            [self.tableView headerEndRefreshing];
            self.course_id = respose[@"data"][@"course_id"];
            NSArray *tmpArray = [SJNewLiewVideoListModel objectArrayWithKeyValuesArray:respose[@"data"][@"programs"]];
            if (tmpArray.count) {
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            } else {
                [MBHUDHelper showWarningWithText:@"暂无数据"];
            }
        } else {
            [MBHUDHelper showWarningWithText:@"获取直播列表失败"];
        }
    } failure:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJLiveVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJLiveVideoListCell"];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SJNewLiewVideoListModel *model = self.dataArray[indexPath.row];
    if ([model.status isEqualToString:@"formerly"]) {
        SJVideoViewController *videoVC = [[SJVideoViewController alloc] init];
        videoVC.course_id = self.course_id;
        videoVC.vod_id = model.vod_id;
        [self.navigationController pushViewController:videoVC animated:YES];
        if (self.skipToVideoCourseBlock) {
            self.skipToVideoCourseBlock();
        }
    } else if ([model.status isEqualToString:@"will"]) {
        [MBHUDHelper showWarningWithText:@"直播尚未开始"];
    } else {
        [MBHUDHelper showWarningWithText:@"正在直播"];
    }
    
}

@end

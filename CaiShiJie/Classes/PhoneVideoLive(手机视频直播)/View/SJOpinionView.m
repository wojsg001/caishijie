//
//  SJOpinionView.m
//  CaiShiJie
//
//  Created by user on 18/7/27.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJOpinionView.h"
#import "SJVideoOpinionModel.h"
#import "SJVideoOpinionVM.h"
#import "SJVideoOpinionCell.h"
#import "MJExtension.h"

@interface SJOpinionView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SJOpinionView

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f5f5f8" withAlpha:1];
        [self setupChildViews];
        [self initLayoutSubviews];
        [self addNotification];
        [SJNoDataView showNoDataViewToView:self];
    }
    return self;
}

- (void)setupChildViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tableView];
}

- (void)initLayoutSubviews {
    WS(weakSelf);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(weakSelf);
    }];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOpinion:) name:KNotificationAddOpinion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLunxunOpinion:) name:KNotificationAddLunXunOpinion object:nil];
}

#pragma mark - 接收添加观点的通知
- (void)addOpinion:(NSNotification *)n {
    [SJNoDataView hideNoDataViewFromView:self];
    NSDictionary *dic = n.object;
    SJVideoOpinionModel *model = [SJVideoOpinionModel objectWithKeyValues:dic];
    SJVideoOpinionVM *opinionVM = [[SJVideoOpinionVM alloc] init];
    opinionVM.isRefresh = NO;
    /**
     这里传入窗口的宽和高，防止横屏时出现宽高交换
     */
    opinionVM.screenWidth = SJScreenW<SJScreenH?SJScreenW:SJScreenH;
    opinionVM.screenHeight = SJScreenH>SJScreenW?SJScreenH:SJScreenW;
    opinionVM.isFullScreen = _isFullScreen;
    opinionVM.videoOpinionModel = model;
    WS(weakSelf);
    opinionVM.updateImageSize = ^(SJVideoOpinionVM *opinionF) {
        opinionF.isRefresh = YES;
        [opinionF setVideoOpinionModel:opinionF.videoOpinionModel];
        [weakSelf.tableView reloadData];
    };
    [self.dataArray addObject:opinionVM];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - 接收添加轮询观点的通知
- (void)addLunxunOpinion:(NSNotification *)n {
    [SJNoDataView hideNoDataViewFromView:self];
    NSArray *array = n.object;
    NSArray *opinionArray = [SJVideoOpinionModel objectArrayWithKeyValuesArray:array];
    for (SJVideoOpinionModel *model in opinionArray) {
        SJVideoOpinionVM *opinionVM = [[SJVideoOpinionVM alloc] init];
        opinionVM.isRefresh = NO;
        opinionVM.screenWidth = SJScreenW<SJScreenH?SJScreenW:SJScreenH;
        opinionVM.screenHeight = SJScreenH>SJScreenW?SJScreenH:SJScreenW;
        opinionVM.isFullScreen = _isFullScreen;
        opinionVM.videoOpinionModel = model;
        WS(weakSelf);
        opinionVM.updateImageSize = ^(SJVideoOpinionVM *opinionF) {
            opinionF.isRefresh = YES;
            [opinionF setVideoOpinionModel:opinionF.videoOpinionModel];
            [weakSelf.tableView reloadData];
        };
        [self.dataArray addObject:opinionVM];
    }
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
}

- (void)tableViewScrollToBottom {
    if (self.dataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat y = scrollView.contentOffset.y;
        if ((scrollView.contentSize.height - self.tableView.frame.size.height - y) < 1.0) {
            // tableview滚动到了底部
            if (self.dataArray.count > 10) {
                NSRange range = NSMakeRange(0, self.dataArray.count - 10);
                [self.dataArray removeObjectsInRange:range];
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoOpinionCell *cell = [SJVideoOpinionCell cellWithTableView:tableView];
    if (self.dataArray.count) {
        cell.videoOpinionVM = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count) {
        SJVideoOpinionVM *opinionVM = self.dataArray[indexPath.row];
        return opinionVM.cellHeight;
    }
    return CGFLOAT_MIN;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SJLog(@"%s", __func__);
}

@end

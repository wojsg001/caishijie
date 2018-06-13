//
//  SJLiveOpenMessageViewController.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLiveOpenMessageViewController.h"
#import "SJLiveOpenMessageCell.h"

@interface SJLiveOpenMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SJLiveOpenMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(245, 245, 248);
    self.navigationItem.title = @"直播";
    [self setupSubViews];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stock_del_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessage)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)setupSubViews {
    _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sixin_live_bag"]];
    [self.view addSubview:_backgroundView];
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_tableView registerNib:[UINib nibWithNibName:@"SJLiveOpenMessageCell" bundle:nil] forCellReuseIdentifier:@"SJLiveOpenMessageCell"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJLiveOpenMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJLiveOpenMessageCell"];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - ClickEnvet
- (void)deleteAllMessage {
    
}

@end

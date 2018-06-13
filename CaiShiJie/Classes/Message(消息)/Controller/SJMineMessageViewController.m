//
//  SJMineMessageViewController.m
//  CaiShiJie
//
//  Created by user on 16/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMineMessageViewController.h"
#import "SJMineMessageCell.h"
#import "SJMineMessageModel.h"
#import "SJCSJMessageViewController.h"
#import "SJMyQuestionViewController.h"
#import "SJUserQuestionViewController.h"
#import "SJLiveOpenMessageViewController.h"
#import "SJChatMessageViewController.h"
#import "SJAddressBookViewController.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "SDAutoLayout.h"
#import "AFNetworking.h"
#import "TSMessage.h"

@interface SJMineMessageViewController ()<UITableViewDelegate, UITableViewDataSource, SJNoWifiViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SJMineMessageModel *curSelModel;

@end

@implementation SJMineMessageViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self setupTableView];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"聊天" style:UIBarButtonItemStylePlain target:self action:@selector(selectedChart)];
    self.navigationItem.rightBarButtonItem = rightButton;
    // 加载聊天列表
    [MBProgressHUD showMessage:@"接收中..." toView:self.view];
    [self loadListData];
    // 接收网络状态改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:KNotificationNetworkStatusChange object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.curSelModel != nil) {
        self.curSelModel.count = @"0";
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.dataArray indexOfObject:self.curSelModel] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    __block NSInteger count = 0;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SJMineMessageModel *model = (SJMineMessageModel *)obj;
        count += [model.count integerValue];
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationChatMessageUnreadCount object:@(count)];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)loadListData {
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/message/recent?user_id=%@&token=%@&time=%@", HOST, instance.userid, instance.token, instance.time];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        if ([respose[@"status"] integerValue]) {
            NSArray *tmpArray = [SJMineMessageModel objectArrayWithKeyValuesArray:respose[@"data"]];
            if (tmpArray.count) {
                [self.dataArray addObjectsFromArray:tmpArray];
                [self.tableView reloadData];
            }
            
            if (!self.dataArray.count) {
                [SJNoDataView showNoDataViewToView:self.view];
            } else {
                [SJNoDataView hideNoDataViewFromView:self.view];
            }
            
            // 数据列表加载完成后接收有新消息的通知
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMQTTData:) name:KNotificationMQTTHaveNewData object:nil];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma mark - NSNotification
- (void)receiveMQTTData:(NSNotification *)n {
    NSDictionary *dictionary = (NSDictionary *)n.object;
    BOOL isInList = NO; // 默认不在列表中
    NSString *user_id = [NSString stringWithFormat:@"%@", dictionary[@"user_id"]];
    NSString *target_id = [NSString stringWithFormat:@"%@", dictionary[@"target_id"]];
    NSString *type = [NSString stringWithFormat:@"%@", dictionary[@"type"]];
    
    SJMineMessageModel *firstModel;
    SJMineMessageModel *secondModel;
    if (self.dataArray.count == 1) {
        firstModel = [self.dataArray firstObject];
    } else if (self.dataArray.count >= 2) {
        firstModel = [self.dataArray firstObject];
        secondModel = [self.dataArray objectAtIndex:1];
    }
    NSInteger chatMessageIndex = 0;
    if (firstModel != nil && secondModel == nil) {
        if ([firstModel.type isEqualToString:@"0"]
            || [firstModel.type isEqualToString:@"30"]) {
            chatMessageIndex = 1;
        } else {
            chatMessageIndex = 0;
        }
    } else if (firstModel != nil && secondModel != nil) {
        if ([firstModel.type isEqualToString:@"0"]
            && [secondModel.type isEqualToString:@"30"]) {
            chatMessageIndex = 2;
        } else if (([firstModel.type isEqualToString:@"0"] || [firstModel.type isEqualToString:@"30"]) && [secondModel.type isEqualToString:@"100"]) {
            chatMessageIndex = 1;
        } else {
            chatMessageIndex = 0;
        }
    } else {
        chatMessageIndex = 0;
    }
    
    for (SJMineMessageModel *model in self.dataArray) {
        // 问股
        if ([type isEqualToString:@"30"] && [model.type isEqualToString:type]) {
            isInList = YES;
            model.nickname = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"nickname"]];
            model.count = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"count"]];
            model.content = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"content"]];
            model.created_at = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"created_at"]];
            model.sn = dictionary[@"sn"];
            NSInteger index = [self.dataArray indexOfObject:model];
            [self.dataArray removeObject:model];
            [self.dataArray insertObject:model atIndex:index];
            break;
        }
        // 系统消息
        if ([type isEqualToString:@"0"] && [model.type isEqualToString:type]) {
            isInList = YES;
            model.count = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"count"]];
            model.content = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"content"]];
            model.created_at = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"created_at"]];
            model.sn = dictionary[@"sn"];
            NSInteger index = [self.dataArray indexOfObject:model];
            [self.dataArray removeObject:model];
            [self.dataArray insertObject:model atIndex:index];
            break;
        }
        // 私信
        if ([user_id isEqualToString:[SJUserDefaults objectForKey:kUserid]]) {
            if ([model.user_id isEqualToString:target_id]) {
                isInList = YES;
                [self.dataArray removeObject:model];
                model.count = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"count"]];
                model.content = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"content"]];
                model.created_at = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"created_at"]];
                model.sn = dictionary[@"sn"];
                [self.dataArray insertObject:model atIndex:chatMessageIndex];
                
                break;
            }
        } else {
            if ([model.user_id isEqualToString:user_id]) {
                isInList = YES;
                [self.dataArray removeObject:model];
                model.count = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"count"]];
                model.content = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"content"]];
                model.created_at = [NSString stringWithFormat:@"%@", dictionary[@"data"][@"created_at"]];
                model.sn = dictionary[@"sn"];
                [self.dataArray insertObject:model atIndex:chatMessageIndex];
                break;
            }
        }
    }
    
    if (!isInList) {
        // 不在列表中，添加到列表
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        if ([user_id isEqualToString:[SJUserDefaults objectForKey:kUserid]]) {
            // 我发的
            [tmpDic setObject:dictionary[@"target_id"] forKey:@"user_id"];
            [tmpDic setObject:dictionary[@"data"][@"target_user"][@"nickname"] forKey:@"nickname"];
            [tmpDic setObject:dictionary[@"data"][@"target_user"][@"head_img"] forKey:@"head_img"];
            [tmpDic setObject:dictionary[@"data"][@"target_user"][@"level"] forKey:@"level"];
            [tmpDic setObject:@"0" forKey:@"count"];
        } else {
            [tmpDic setObject:dictionary[@"user_id"] forKey:@"user_id"];
            [tmpDic setObject:dictionary[@"data"][@"nickname"] forKey:@"nickname"];
            [tmpDic setObject:dictionary[@"data"][@"head_img"] forKey:@"head_img"];
            [tmpDic setObject:dictionary[@"data"][@"level"] forKey:@"level"];
            [tmpDic setObject:dictionary[@"data"][@"count"] forKey:@"count"];
        }
        [tmpDic setObject:dictionary[@"data"][@"content"] forKey:@"content"];
        [tmpDic setObject:dictionary[@"data"][@"created_at"] forKey:@"created_at"];
        [tmpDic setObject:dictionary[@"type"] forKey:@"type"];
        [tmpDic setObject:dictionary[@"sn"] forKey:@"sn"];
        //SJLog(@"%@", tmpDic);
        
        SJMineMessageModel *model = [SJMineMessageModel objectWithKeyValues:tmpDic];
        if ([model.type isEqualToString:@"100"]) {
            [self.dataArray insertObject:model atIndex:chatMessageIndex];
        } else if ([model.type isEqualToString:@"0"]) {
            [self.dataArray insertObject:model atIndex:0];
        } else if ([model.type isEqualToString:@"30"]) {
            if (firstModel != nil && [firstModel.type isEqualToString:@"0"]) {
                [self.dataArray insertObject:model atIndex:1];
            } else {
                [self.dataArray insertObject:model atIndex:0];
            }
        }
    }
    [self.tableView reloadData];
}

- (void)networkStatusChange:(NSNotification *)n {
    NSNumber *state = n.object;
    AFNetworkReachabilityStatus status = [state integerValue];
    if (status == AFNetworkReachabilityStatusNotReachable) {
        // 无网络
        [TSMessage showNotificationInViewController:self
                                              title:nil
                                           subtitle:@"当前网络不可用，请检查你的网络设置"
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationEndless
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:NO];
    } else {
        [TSMessage dismissActiveNotification];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJMineMessageCell *cell = [SJMineMessageCell cellWithTableView:tableView];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 75, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
    }
    
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
        WS(weakSelf);
        cell.buttonClickedBlock = ^(UIButton *button) {
            switch (button.tag) {
                case 101:
                    // 删除
                    [weakSelf deleteMessageWithModel:weakSelf.dataArray[indexPath.row] indexPath:indexPath];
                    break;
                    
                default:
                    break;
            }
        };
    }
    
    return cell;
}

- (void)deleteMessageWithModel:(SJMineMessageModel *)model indexPath:(NSIndexPath *)indexPath {
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/message/hide?sn=%@&user_id=%@&token=%@&time=%@", HOST, model.sn, [SJUserDefaults objectForKey:kUserid], instance.token, instance.time];
    SJLog(@"%@", urlStr);
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        SJLog(@"%@", respose);
        if ([respose[@"status"] integerValue]) {
            [self.dataArray removeObject:model];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJMineMessageModel *model = self.dataArray[indexPath.row];
    self.curSelModel = model;
    if ([model.type isEqualToString:@"30"]) {
        // 告诉服务器清除badgeValue
        [self sendClearBadgeValueToHostWithTargetID:[SJUserDefaults objectForKey:kUserid] userID:[SJUserDefaults objectForKey:kUserid] type:model.type];
        NSDictionary *dic = [SJUserDefaults objectForKey:kUserInfo];
        if ([dic[@"level"] isEqualToString:@"10"]) {
            SJMyQuestionViewController *myQuestionVC = [[SJMyQuestionViewController alloc] init];
            [self.navigationController pushViewController:myQuestionVC animated:YES];
        } else {
            SJUserQuestionViewController *myQuestionVC = [[SJUserQuestionViewController alloc] init];
            [self.navigationController pushViewController:myQuestionVC animated:YES];
        }
    } else if ([model.type isEqualToString:@"0"]) {
        // 告诉服务器清除badgeValue
        [self sendClearBadgeValueToHostWithTargetID:[SJUserDefaults objectForKey:kUserid] userID:[SJUserDefaults objectForKey:kUserid] type:model.type];
        
        SJCSJMessageViewController *csjMessageVC = [[SJCSJMessageViewController alloc] init];
        csjMessageVC.navigationItem.title = @"财视界通知";
        [self.navigationController pushViewController:csjMessageVC animated:YES];
    } else {
        // 告诉服务器清除badgeValue
        [self sendClearBadgeValueToHostWithTargetID:[SJUserDefaults objectForKey:kUserid] userID:model.user_id type:model.type];
        
        SJChatMessageViewController *chatMessageVC = [[SJChatMessageViewController alloc] init];
        chatMessageVC.navigationItem.title = model.nickname;
        chatMessageVC.target_id = model.user_id;
        [self.navigationController pushViewController:chatMessageVC animated:YES];
    }
}

- (void)sendClearBadgeValueToHostWithTargetID:(NSString *)target_id userID:(NSString *)user_id type:(NSString *)type {
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/message/read?target_id=%@&user_id=%@&type=%@&token=%@&time=%@", HOST, target_id, user_id, type, instance.token, instance.time];
    SJLog(@"%@", urlStr);
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        SJLog(@"%@", respose[@"data"]);
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

#pragma mark - ClickEvent
- (void)selectedChart {
    SJAddressBookViewController *addressBookVC = [[SJAddressBookViewController alloc] init];
    addressBookVC.navigationItem.title = @"发起聊天";
    [self.navigationController pushViewController:addressBookVC animated:YES];
}

#pragma mark - SJNoDataViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES) {
        [MBProgressHUD showMessage:@"接收中..." toView:self.view];
        [self loadListData];
    }
}

- (void)dealloc {
    SJLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

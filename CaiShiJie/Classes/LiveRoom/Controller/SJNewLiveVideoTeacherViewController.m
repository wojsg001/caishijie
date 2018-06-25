//
//  SJNewLiveVideoTeacherViewController.m
//  CaiShiJie
//
//  Created by user on 18/9/1.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJNewLiveVideoTeacherViewController.h"
#import "SJLiveVideoTeacherCell.h"
#import "SJLiveVideoTeacherSummaryView.h"
#import <BlocksKit/NSArray+BlocksKit.h>
#import "SJhttptool.h"
#import "SJNewLiveVideoTeacherModel.h"
#import "MJExtension.h"
#import "SJUserInfo.h"
#import "SJToken.h"
#import "SJNetManager.h"
#import "SJLoginViewController.h"

@interface SJNewLiveVideoTeacherViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *popupViewBackground;
@property (nonatomic, strong) SJLiveVideoTeacherSummaryView *popupView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *attentionArray;

@end

@implementation SJNewLiveVideoTeacherViewController

- (NSMutableArray *)attentionArray {
    if (_attentionArray == nil) {
        _attentionArray = [NSMutableArray array];
    }
    return _attentionArray;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)popupViewBackground {
    if (!_popupViewBackground) {
        _popupViewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, SJScreenH)];
        _popupViewBackground.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.0];
    }
    return _popupViewBackground;
}

- (SJLiveVideoTeacherSummaryView *)popupView {
    if (!_popupView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJNewLiewVideoUI" owner:nil options:nil];
        _popupView = [nib bk_match:^BOOL(id obj) {
            return [obj isKindOfClass:[SJLiveVideoTeacherSummaryView class]];
        }];
        _popupView.frame = CGRectMake(20, SJScreenH, SJScreenW - 40, 300);
        WS(weakSelf);
        _popupView.removePopupViewBlock = ^() {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.popupViewBackground.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.0];
                CGRect rect = weakSelf.popupView.frame;
                rect.origin.y = SJScreenH;
                weakSelf.popupView.frame =rect;
            } completion:^(BOOL finished) {
                [weakSelf.popupView removeFromSuperview];
                [weakSelf.popupViewBackground removeFromSuperview];
                weakSelf.popupView = nil;
                weakSelf.popupViewBackground = nil;
            }];
        };
    }
    return _popupView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildViews];
    [self loadVideoTeacherData];
    [self receiveNotification];
}

- (void)setupChildViews {
    WS(weakSelf);
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [_tableView registerNib:[UINib nibWithNibName:@"SJLiveVideoTeacherCell" bundle:nil] forCellReuseIdentifier:@"SJLiveVideoTeacherCell"];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(weakSelf.view);
    }];
}

- (void)loadVideoTeacherData {
    // 如果登录过，先获取当前用户关注过的投顾
    if ([[SJUserInfo sharedUserInfo] isSucessLogined]) {
        [self loadMineAttentionData];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/live/guests?user_id=%@", HOST, self.target_id];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"老师列表%@", respose);
        if ([respose[@"status"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJNewLiveVideoTeacherModel objectArrayWithKeyValuesArray:respose[@"data"]];
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
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 加载用户关注过的投顾
- (void)loadMineAttentionData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/focusteacher",HOST];
    SJToken *token = [SJToken sharedToken];
    
    [SJhttptool GET:urlStr paramers:token.keyValues success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            for (NSDictionary *dic in respose[@"data"]) {
                NSString *str = [NSString stringWithFormat:@"%@",dic[@"attention_user_id"]];
                [self.attentionArray addObject:str];
            }
            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 接收通知
- (void)receiveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
}

- (void)loginSuccess {
    [self loadMineAttentionData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJLiveVideoTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJLiveVideoTeacherCell"];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    SJNewLiveVideoTeacherModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    if ([self.attentionArray containsObject:model.user_id]) {
        [cell.guanzhuButton setImage:[UIImage imageNamed:@"index_account_icon_n"] forState:UIControlStateNormal];
        cell.guanzhuButton.enabled = NO;
    } else {
        [cell.guanzhuButton setImage:[UIImage imageNamed:@"index_account_icon_h"] forState:UIControlStateNormal];
        cell.guanzhuButton.enabled = YES;
    }
    // 加关注
    cell.guanzhuButton.tag = indexPath.row;
    [cell.guanzhuButton addTarget:self action:@selector(clickguanzhuButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

// 添加关注
- (void)clickguanzhuButton:(UIButton *)button {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    SJNewLiveVideoTeacherModel *model = self.dataArray[button.tag];
    SJToken *Token = [SJToken sharedToken];
    
    [[SJNetManager sharedNetManager] addAttentionWithToken:Token.token andUserid:Token.userid andTime:Token.time andTargetid:model.user_id withSuccessBlock:^(NSDictionary *dict) {
        
        if ([dict[@"states"] isEqual:@"1"]) {
            [button setImage:[UIImage imageNamed:@"index_account_icon_n"] forState:UIControlStateNormal];
            button.enabled = NO;
            // 提示用户关注成功
            [MBProgressHUD showSuccess:@"关注成功"];
        } else {
            [MBHUDHelper showWarningWithText:dict[@"data"]];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.popupView.model = self.dataArray[indexPath.row];
    [self.popupViewBackground addSubview:self.popupView];
    [SJKeyWindow addSubview:self.popupViewBackground];
    [UIView animateWithDuration:0.3 animations:^{
        self.popupViewBackground.backgroundColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:0.5];
        CGRect rect = self.popupView.frame;
        rect.origin.y = (SJScreenH - 300)/2;
        self.popupView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

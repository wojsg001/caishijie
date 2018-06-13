//
//  SJSearchTeacherViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJSearchTeacherViewController.h"
#import "Masonry.h"
#import "SJIntoTeacherCell.h"
#import "SJhttptool.h"
#import "SJCustom.h"
#import "MJExtension.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "SJLoginViewController.h"
#import "SJNetManager.h"
#import "SJMyLiveViewController.h"
#import "SJNewLiveRoomViewController.h"
#import "SJPersonalCenterViewController.h"

@interface SJSearchTeacherViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *attentionArray;

@end

@implementation SJSearchTeacherViewController

- (NSMutableArray *)attentionArray
{
    if (_attentionArray == nil)
    {
        _attentionArray = [NSMutableArray array];
    }
    return _attentionArray;
}

- (NSMutableArray *)resultArray
{
    if (_resultArray == nil)
    {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self initChildViews];
    // 接收登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNotificationLoginSuccess object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loginSuccess
{
    [self loadMineAttentionData];
}

- (void)initChildViews
{
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.keyboardType = UIKeyboardAppearanceDefault;
    _searchBar.placeholder = @"搜索投顾";
    _searchBar.delegate = self;
    _searchBar.barTintColor = RGB(245, 245, 248);
    _searchBar.layer.borderColor = RGB(245, 245, 248).CGColor;
    _searchBar.layer.borderWidth = 1;
    _searchBar.searchBarStyle = UISearchBarStyleDefault;
    _searchBar.barStyle = UIBarStyleDefault;
    UITextField *searchTextField = [[[_searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.layer.borderColor = RGB(227, 227, 227).CGColor
    ;
    searchTextField.layer.borderWidth = 0.5f;
    searchTextField.layer.cornerRadius = 4.0f;
    searchTextField.layer.masksToBounds = YES;
    [self.view addSubview:_searchBar];
    
    WS(weakSelf);
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(44);
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.searchBar.mas_bottom).offset(0);
    }];
    
    [_tableView registerNib:[UINib nibWithNibName:@"SJIntoTeacherCell" bundle:nil] forCellReuseIdentifier:@"SJIntoTeacherCell"];
}

#pragma mark - 获取搜索结果
- (void)loadSearchResultWithString:(NSString *)text
{
    // 如果登录过，先获取当前用户关注过的投顾
    if ([[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        [self loadMineAttentionData];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/search/live",HOST];
    NSDictionary *dic = @{@"name":text,@"pageindex":@"1",@"pagesize":@"10"};
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *tmpArr = [SJCustom objectArrayWithKeyValuesArray:respose[@"data"][@"live"]];
            if (tmpArr.count)
            {
                [self.resultArray removeAllObjects];
                [self.resultArray addObjectsFromArray:tmpArr];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 加载用户关注过的投顾
- (void)loadMineAttentionData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/focusteacher",HOST];
    SJToken *token = [SJToken sharedToken];
    
    [SJhttptool GET:urlStr paramers:token.keyValues success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            for (NSDictionary *dic in respose[@"data"])
            {
                NSString *str = [NSString stringWithFormat:@"%@",dic[@"attention_user_id"]];
                [self.attentionArray addObject:str];
            }
            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJIntoTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJIntoTeacherCell"];
    
    if (self.resultArray.count)
    {
        SJCustom *model = self.resultArray[indexPath.row];
        cell.model = model;
        if ([self.attentionArray containsObject:model.user_id])
        {
            [cell.addAttentionBtn setImage:[UIImage imageNamed:@"index_account_icon_n"] forState:UIControlStateNormal];
            cell.addAttentionBtn.enabled = NO;
        }
        else
        {
            [cell.addAttentionBtn setImage:[UIImage imageNamed:@"index_account_icon_h"] forState:UIControlStateNormal];
            cell.addAttentionBtn.enabled = YES;
        }
        
        // 加关注
        cell.addAttentionBtn.tag = indexPath.row;
        [cell.addAttentionBtn addTarget:self action:@selector(clickAddAttentionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

// 添加关注
- (void)clickAddAttentionButton:(UIButton *)button
{
    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    SJCustom *model = self.resultArray[button.tag];
    SJToken *Token = [SJToken sharedToken];
    
    [[SJNetManager sharedNetManager] addAttentionWithToken:Token.token andUserid:Token.userid andTime:Token.time andTargetid:model.user_id withSuccessBlock:^(NSDictionary *dict) {
        
        if ([dict[@"states"] isEqual:@"1"])
        {
            [button setImage:[UIImage imageNamed:@"index_account_icon_n"] forState:UIControlStateNormal];
            button.enabled = NO;
            // 提示用户关注成功
            [MBProgressHUD showSuccess:@"关注成功"];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = RGB(227, 227, 227);
    [view addSubview:topLine];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = RGB(227, 227, 227);
    [view addSubview:bottomLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(view);
        make.height.mas_equalTo(0.5);
    }];
    
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(view);
        make.height.mas_equalTo(0.5);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"搜索结果";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = RGB(132, 132, 132);
    [view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(10);
        make.centerY.mas_equalTo(view);
    }];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SJCustom *model = self.resultArray[indexPath.row];
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
    [self.searchBar resignFirstResponder];
    SJPersonalCenterViewController *personalCenterVC = [[SJPersonalCenterViewController alloc] init];
    personalCenterVC.target_id = model.user_id;
    [self.navigationController pushViewController:personalCenterVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

//-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    searchBar.showsCancelButton = YES;
//    [searchBar setShowsCancelButton:YES animated:YES];
//    
//    for (UIView *view in [[[searchBar subviews] objectAtIndex:0] subviews]) {
//        if ([view isKindOfClass:[UIButton class]]) {
//            UIButton *cancel = (UIButton *)view;
//            [cancel setTitle:@"取消" forState:UIControlStateNormal];
//            [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        }
//    }
//}

// 取消的响应事件
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}
// 键盘上搜索事件的响应
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!text.length) {
        [MBHUDHelper showWarningWithText:@"请输入搜索内容！"];
        return;
    }
    
    [self loadSearchResultWithString:text];
}

// 搜框中输入关键字的事件响应
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!text.length && self.resultArray.count) {
        [self.resultArray removeAllObjects];
        [self.tableView reloadData];
    } else {
        [self loadSearchResultWithString:text];
    }
}

@end

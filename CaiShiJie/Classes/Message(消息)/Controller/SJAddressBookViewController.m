//
//  SJAddressBookViewController.m
//  CaiShiJie
//
//  Created by user on 18/10/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAddressBookViewController.h"
#import "SJMineFansViewController.h"
#import "SJAddressBookSearchResultView.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "SJMineFansModel.h"
#import "SJChatMessageViewController.h"

#define TitleMaxWidth 70
#define TitleLineMaxWidth 80

@interface SJAddressBookViewController ()<UISearchBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *titleBackgroundView;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) UIView *titleLine;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) SJAddressBookSearchResultView *resultView;
@property (nonatomic, assign) BOOL isHiddenNavigationBar;

@end

@implementation SJAddressBookViewController

- (SJAddressBookSearchResultView *)resultView {
    if (!_resultView) {
        _resultView = [[SJAddressBookSearchResultView alloc] init];
        _resultView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor;
        _resultView.layer.borderWidth = 0.5f;
    }
    return _resultView;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(245, 245, 248);
    [self addChildViewControllers];
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SJKeyWindow.backgroundColor = RGB(245, 245, 248);
    [self.navigationController setNavigationBarHidden:self.isHiddenNavigationBar animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    SJKeyWindow.backgroundColor = [UIColor blackColor];
}

- (void)addChildViewControllers {
    SJToken *instance = [SJToken sharedToken];
    SJMineFansViewController *mineFansVC = [[SJMineFansViewController alloc] init];
    mineFansVC.urlStr = [NSString stringWithFormat:@"%@/mobile/user/findfansbyuserid?userid=%@", HOST, instance.userid];
    SJMineFansViewController *mineAttentionVC = [[SJMineFansViewController alloc] init];
    mineAttentionVC.urlStr = [NSString stringWithFormat:@"%@/mobile/user/findbyattentions?userid=%@", HOST, instance.userid];
    [self addChildViewController:mineFansVC];
    [self addChildViewController:mineAttentionVC];
}

- (void)setupSubViews {
    WS(weakSelf);
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.keyboardType = UIKeyboardAppearanceDefault;
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    _searchBar.barTintColor = RGB(245, 245, 248);
    _searchBar.layer.borderColor = RGB(245, 245, 248).CGColor;
    _searchBar.layer.borderWidth = 1;
    _searchBar.searchBarStyle = UISearchBarStyleDefault;
    _searchBar.barStyle = UIBarStyleDefault;
    UITextField *searchTextField = [[[_searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor
    ;
    searchTextField.layer.borderWidth = 0.5f;
    searchTextField.layer.cornerRadius = 4.0f;
    searchTextField.layer.masksToBounds = YES;
    [self.view addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(47);
    }];
    
    _titleBackgroundView = [[UIView alloc] init];
    _titleBackgroundView.backgroundColor = [UIColor whiteColor];
    _titleBackgroundView.layer.borderColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1].CGColor
    ;
    _titleBackgroundView.layer.borderWidth = 0.5f;
    [self.view addSubview:_titleBackgroundView];
    [_titleBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(weakSelf.searchBar.mas_bottom).offset(0);
        make.height.mas_equalTo(44);
    }];
    
    [self setUpButtonWithTitle:@"我的粉丝" tag:101 target:self action:@selector(titleButtonClicked:)];
    [self setUpButtonWithTitle:@"我关注的" tag:102 target:self action:@selector(titleButtonClicked:)];
    
    for (UIButton *button in self.titleArray) {
        if ([self.titleArray indexOfObject:button] == 0) {
            button.selected = YES;
        }
        CGFloat spaceX = (SJScreenW-TitleMaxWidth*2)/4;
        button.frame = CGRectMake(spaceX+(TitleMaxWidth+2*spaceX)*[self.titleArray indexOfObject:button], 0, TitleMaxWidth, 44);
        [self.titleBackgroundView addSubview:button];
    }
    
    CGFloat spaceX = (SJScreenW-TitleLineMaxWidth*2)/4;
    _titleLine = [[UIView alloc] initWithFrame:CGRectMake(spaceX, 42, TitleLineMaxWidth, 2)];
    _titleLine.backgroundColor = [UIColor colorWithHexString:@"#f76408" withAlpha:1];
    [self.titleBackgroundView addSubview:_titleLine];
    
    _contentScrollView = [[UIScrollView alloc] init];
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_contentScrollView];
    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.equalTo(weakSelf.titleBackgroundView.mas_bottom).offset(0);
    }];
    CGFloat contentX = self.childViewControllers.count * SJScreenW;
    _contentScrollView.contentSize = CGSizeMake(contentX, 0);
    
    // 添加默认控制器
    UIViewController *firstVC = [self.childViewControllers firstObject];
    firstVC.view.frame = self.contentScrollView.bounds;
    [self.contentScrollView addSubview:firstVC.view];
}

- (void)setUpButtonWithTitle:(NSString *)title tag:(NSInteger)tag target:(id)target action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#646464" withAlpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#f76408" withAlpha:1] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;

    [self.titleArray addObject:button];
}

#pragma mark - ClickEvent
- (void)titleButtonClicked:(UIButton *)button {
    if (button.selected) {
        return;
    }
    
    button.selected = YES;
    for (UIButton *tmpButton in self.titleArray) {
        if (tmpButton != button) {
            tmpButton.selected = NO;
        }
    }
    NSUInteger index = button.tag - 101;
    [self.contentScrollView setContentOffset:CGPointMake(SJScreenW * index, 0) animated:NO];
    
    [self titleLineMoveWithIndex:index];
    [self changeChildViewControllerWithIndex:index];
}

- (void)titleLineMoveWithIndex:(NSInteger)index {
    CGFloat spaceX = (SJScreenW-TitleLineMaxWidth*2)/4;
    CGRect titleLineRect = self.titleLine.frame;
    titleLineRect.origin.x = spaceX+(TitleLineMaxWidth+2*spaceX)*index;
    self.titleLine.frame = titleLineRect;
}

- (void)changeChildViewControllerWithIndex:(NSInteger)index {
    UIViewController *newVC = self.childViewControllers[index];
    if (newVC.view.superview) return;
    newVC.view.frame = self.contentScrollView.bounds;
    [self.contentScrollView addSubview:newVC.view];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    WS(weakSelf);
    if (!self.isHiddenNavigationBar) {
        self.resultView.cancelKeyboardBlock = ^() {
            [weakSelf.searchBar resignFirstResponder];
            UIButton *cancelButton = [searchBar valueForKey:@"cancelButton"];
            cancelButton.enabled = YES;
        };
        self.resultView.didSelectRowBlock = ^(SJMineFansModel *model) {
            [weakSelf.searchBar resignFirstResponder];
            SJChatMessageViewController *chatMessageVC = [[SJChatMessageViewController alloc] init];
            chatMessageVC.navigationItem.title = model.nickname;
            chatMessageVC.target_id = model.user_id;
            [weakSelf.navigationController pushViewController:chatMessageVC animated:YES];
        };
        [self.view addSubview:self.resultView];
        [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.top.equalTo(self.searchBar.mas_bottom).offset(0);
        }];
        [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
        }];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.isHiddenNavigationBar = YES;
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
    }];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.isHiddenNavigationBar = NO;
    [self.resultView removeFromSuperview];
    self.resultView = nil;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    for (id searchButton in [[searchBar.subviews lastObject] subviews]) {
        if ([searchButton isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton *)searchButton;
            [cancelButton setTitleColor:[UIColor colorWithHexString:@"#444444" withAlpha:1] forState:UIControlStateNormal];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!text.length) {
        self.resultView.dataArray = [NSArray array];
        return;
    }
    [self loadSearchResultWithString:text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!text.length) {
        self.resultView.dataArray = [NSArray array];
        return;
    }
    [self loadSearchResultWithString:text];
}

- (void)loadSearchResultWithString:(NSString *)text {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/findrelation?userid=%@&nickname=%@", HOST, [SJUserDefaults objectForKey:kUserid], text];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        if ([respose[@"status"] integerValue]) {
            NSArray *tmpArray = [SJMineFansModel objectArrayWithKeyValuesArray:respose[@"data"]];
            self.resultView.dataArray = tmpArray;
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / self.contentScrollView.frame.size.width;
    for (UIButton *button in self.titleArray) {
        if (button.tag == index + 101) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    [self titleLineMoveWithIndex:index];
    [self changeChildViewControllerWithIndex:index];
}

@end

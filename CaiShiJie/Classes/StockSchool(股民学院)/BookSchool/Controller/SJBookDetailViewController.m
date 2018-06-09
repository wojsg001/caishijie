//
//  SJBookDetailViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/19.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBookDetailViewController.h"
#import "SJBookDetailHeadCell.h"
#import "SJBookDetailHead.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "SJBookSectionCell.h"
#import "SJBookChapterCell.h"
#import "SJBookDetailFootView.h"
#import "SJBookListModel.h"
#import "SJBookSectionModel.h"
#import "SJhttptool.h"
#import "SJBookChapterModel.h"
#import "MJExtension.h"
#import "SJBookContentViewController.h"

@interface SJBookDetailViewController ()<UITableViewDelegate, UITableViewDataSource,SJBookDetailFootViewDelegate>
{
    int currentPage;
    int allPage;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView               *headerView;
@property (nonatomic, strong) NSMutableArray       *dataSource;
@property (nonatomic, strong) SJBookDetailFootView *tableViewFootView;
@property (nonatomic, copy  ) NSString             *order;
@property (nonatomic, strong) NSMutableArray       *contentArr;

@end

@implementation SJBookDetailViewController

-(NSMutableArray *)contentArr
{
    if (!_contentArr)
    {
        _contentArr = [NSMutableArray array];
    }
    return _contentArr;
}

- (UIView *)headerView
{
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 44)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = RGB(68, 68, 68);
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.text = @"章节";
        [_headerView addSubview:titleLabel];
        WS(weakSelf);
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.headerView.mas_left).offset(10);
            make.centerY.equalTo(weakSelf.headerView.mas_centerY).offset(0);
        }];
    }
    return _headerView;
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

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数据
    [self initData];
    // 设置表格
    [self setUpTableView];

    SJBookDetailHead *model = [[SJBookDetailHead alloc] init];
    model.cover_img = _bookListModel.cover_img;
    model.title = _bookListModel.title;
    model.author = _bookListModel.author;
    model.publication_at = _bookListModel.publication_at;
    model.summary = _bookListModel.summary;
    model.isExpand = NO;
    [self.dataSource addObject:model];
    
    // 加载书籍章节
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadBookChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10" and:self.order];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"live_up_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBtn;

}

- (void)initData
{
    currentPage = 1;
    allPage = 1;
    self.order = @"asc";
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 加载书籍章节
- (void)loadBookChapterDataWith:(NSString *)pageindex and:(NSString *)pagesize and:(NSString *)order
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/book/find",HOST];
    NSDictionary *dic = @{@"bookid":_bookListModel.book_id,@"pageindex":pageindex,@"pagesize":pagesize,@"order":order};
    
    [SJhttptool GET:urlStr paramers:dic success:^(id respose) {
        SJLog(@"%@",respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSArray *chaptersArray = [SJBookChapterModel objectArrayWithKeyValuesArray:respose[@"data"][@"chapters"]];
            NSArray *sectionArray = [SJBookSectionModel objectArrayWithKeyValuesArray:respose[@"data"][@"directory"]];
            
            if (chaptersArray.count)
            {
                // 清空数组
                [self.contentArr removeAllObjects];
                
                for (SJBookChapterModel *chapterModel in chaptersArray)
                {
                    if ([chapterModel.parent_id isEqualToString:@"0"])
                    {
                        SJBookSectionModel *sectionModel = [[SJBookSectionModel alloc] init];
                        sectionModel.chapter_id = chapterModel.chapter_id;
                        sectionModel.title = chapterModel.title;
                        sectionModel.isCanClick = YES; // 父标题能够点击
                        
                        [self.contentArr addObject:sectionModel];
                    }
                    else
                    {
                        for (SJBookSectionModel *sectionModel in sectionArray)
                        {
                            if ([sectionModel.chapter_id isEqualToString:chapterModel.parent_id])
                            {
                                if ([self.contentArr containsObject:sectionModel])
                                {
                                    [self.contentArr addObject:chapterModel];
                                }
                                else
                                {
                                    sectionModel.isCanClick = NO; // 父标题不能点击
                                    [self.contentArr addObject:sectionModel];
                                    [self.contentArr addObject:chapterModel];
                                }
                            }
                        }
                    }
                }
            }
            
            
            int count = [respose[@"data"][@"count"] intValue];
            if (count%10 == 0)
            {
                allPage = count/10;
            }
            else
            {
                allPage = count/10 + 1;
            }
            
            [self.tableView reloadData];
            // 给tableFootView界面赋值
            self.tableViewFootView.currentPageLabel.text = [NSString stringWithFormat:@"第%i页",currentPage];
            self.tableViewFootView.allPageLabel.text = [NSString stringWithFormat:@"共%i页",allPage];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UINib *nib1 = [UINib nibWithNibName:@"SJBookSectionCell" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"SJBookSectionCell"];
    
    UINib *nib2 = [UINib nibWithNibName:@"SJBookChapterCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"SJBookChapterCell"];
    
    self.tableView.tableFooterView = self.tableViewFootView;
}

#pragma mark - UITableViewDataSource 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.contentArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    if (indexPath.section == 0)
    {
        SJBookDetailHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
        {
            cell = [[SJBookDetailHeadCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        SJBookDetailHead *model = nil;
        if (indexPath.row < self.dataSource.count) {
            model = [self.dataSource objectAtIndex:indexPath.row];
        }
        [cell configCellWithModel:model];
        
        cell.expandBlock = ^(BOOL isExpand)
        {
            model.isExpand = isExpand;
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        };
        
        cell.startReadButton.tag = indexPath.row + 101;
        [cell.startReadButton addTarget:self action:@selector(startReadButtonClickDown:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        id value = self.contentArr[indexPath.row];
        
        if ([value isKindOfClass:[SJBookSectionModel class]])
        {
            SJBookSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJBookSectionCell"];
            cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
            
            SJBookSectionModel *sectionModel = (SJBookSectionModel *)value;
            cell.titleLabel.text = sectionModel.title;
            
            if (sectionModel.isCanClick == NO)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            
            return cell;
        }
        else if ([value isKindOfClass:[SJBookChapterModel class]])
        {
            SJBookChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJBookChapterCell"];
            cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
            
            SJBookChapterModel *chapterModel = (SJBookChapterModel *)value;
            cell.titleLabel.text = chapterModel.title;
            
            return cell;
        }
        
        return [UITableViewCell new];
    }
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        SJBookDetailHead *model = nil;
        if (indexPath.row < self.dataSource.count) {
            model = [self.dataSource objectAtIndex:indexPath.row];
        }
        
        NSString *stateKey = nil;
        if (model.isExpand) {
            stateKey = @"expanded";
        } else {
            stateKey = @"unexpanded";
        }
        
        return [SJBookDetailHeadCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            SJBookDetailHeadCell *cell = (SJBookDetailHeadCell *)sourceCell;
            // 配置数据
            [cell configCellWithModel:model];
        } cache:^NSDictionary *{
            return @{kHYBCacheUniqueKey: [NSString stringWithFormat:@"%@", model.title],
                     kHYBCacheStateKey : stateKey,
                     // 如果设置为YES，若有缓存，则更新缓存，否则直接计算并缓存
                     // 主要是对社交这种有动态评论等不同状态，高度也会不同的情况的处理
                     kHYBRecalculateForStateKey : @(NO) // 标识不用重新更新
                     };
        }];
    }
    else
    {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return self.headerView;
    }
    
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 44;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 10;
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        id value = self.contentArr[indexPath.row];
        
        if ([value isKindOfClass:[SJBookSectionModel class]])
        {
            SJBookSectionModel *sectionModel = (SJBookSectionModel *)value;
            
            // 如果父标题可以点击
            if (sectionModel.isCanClick == YES)
            {
                SJBookContentViewController *bookContentVC = [[SJBookContentViewController alloc] init];
                bookContentVC.chapterid = sectionModel.chapter_id;
                bookContentVC.navigationItem.title = sectionModel.title;
                
                [self.navigationController pushViewController:bookContentVC animated:YES];
            }
        }
        else if ([value isKindOfClass:[SJBookChapterModel class]])
        {
            SJBookChapterModel *chapterModel = (SJBookChapterModel *)value;
            
            SJBookContentViewController *bookContentVC = [[SJBookContentViewController alloc] init];
            bookContentVC.chapterid = chapterModel.chapter_id;
            bookContentVC.navigationItem.title = chapterModel.title;
            
            [self.navigationController pushViewController:bookContentVC animated:YES];
        }
    }
}

#pragma mark - 开始阅读
- (void)startReadButtonClickDown:(UIButton *)sender
{
    if (self.contentArr.count)
    {
        SJBookChapterModel *bookChapterModel = self.contentArr[0];
        
        SJBookContentViewController *bookContentVC = [[SJBookContentViewController alloc] init];
        bookContentVC.chapterid = bookChapterModel.chapter_id;
        bookContentVC.navigationItem.title = bookChapterModel.title;
        
        [self.navigationController pushViewController:bookContentVC animated:YES];
    }
}

#pragma mark SJBookDetailFootViewDelegate 代理方法
// 首页
- (void)firstPageBtnClickDown
{
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
    [self loadBookChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10" and:self.order];
}
// 上一页
- (void)beforePageBtnClickDown
{
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
    [self loadBookChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10" and:self.order];
    
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
// 下一页
- (void)nextPageBtnClickDown
{
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
    [self loadBookChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10" and:self.order];
    
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
// 尾页
- (void)lastPageBtnClickDown
{
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
    [self loadBookChapterDataWith:[NSString stringWithFormat:@"%i",currentPage] and:@"10" and:self.order];
}

@end

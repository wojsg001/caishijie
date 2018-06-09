//
//  SJReportViewController.m
//  CaiShiJie
//
//  Created by user on 16/2/17.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJReportViewController.h"
#import "SJReportTableViewCell.h"
#import "SJReportDetailViewController.h"

@interface SJReportViewController ()
{
    NSArray *contentArr;
}
@end

@implementation SJReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    contentArr = @[@"欺诈",@"色情",@"政治谣言",@"常识性谣言",@"诱导分析",@"恶意营销",@"隐私信息收集",@"抄袭公众号文章",@"其他侵权类（冒名、诽谤、抄袭）",@"违规声明原创"];
    
    self.title = @"举报";
    self.view.backgroundColor = RGB(247, 247, 249);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"SJReportTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SJReportTableViewCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return contentArr.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJReportTableViewCell"];
    
    if ([self.lastSelIndexPath isEqual:indexPath])
    {
        cell.selectView.hidden = NO;
    }
    else
    {
        cell.selectView.hidden = YES;
    }
    
    cell.contentLabel.text = contentArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = RGB(247, 247, 249);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"请选择举报原因";
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = RGB(153, 153, 153);
        titleLabel.center = CGPointMake(15, 12);
        [titleLabel sizeToFit];
        
        [view addSubview:titleLabel];
        
        return view;
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = RGB(247, 247, 249);
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, SJScreenW - 30, 43)];
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"login_btn_n"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"login_btn_h"] forState:UIControlStateHighlighted];
        
        [btn addTarget:self action:@selector(nextBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:btn];
        
        return view;
    }
}

- (void)nextBtn
{
    SJReportDetailViewController *reportDetailVC = [[SJReportDetailViewController alloc] initWithNibName:@"SJReportDetailViewController" bundle:nil];
    
    [self.navigationController pushViewController:reportDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 40;
    }
    else
    {
        return 80;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消表格本身的选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SJReportTableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.lastSelIndexPath isEqual:indexPath])
    {
        return;
    }
    else
    {
        SJReportTableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastSelIndexPath];
        oldCell.selectView.hidden = YES;
        
        newCell.selectView.hidden = NO;
        self.lastSelIndexPath = indexPath;
    }
    
}


@end

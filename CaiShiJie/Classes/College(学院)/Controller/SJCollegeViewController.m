//
//  SJCollegeViewController.m
//  CaiShiJie
//
//  Created by zhongtou on 2018/7/13.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCollegeViewController.h"
#import "SJCollegeTableViewCell.h"
#import "ATJWebViewController.h"

@interface SJCollegeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *collegeInfoTableView;
@property (nonatomic,strong) NSArray * collegeInfoList;
@end

@implementation SJCollegeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"中投教育学院";
    
    //创建一个数组，存储需要显示的数据
    _collegeInfoList = @[@"学院简介",@"名师荟萃",@"学员风采",@"教学环境",@"联系我们"];
    
    // 设置tableView的数据源
    self.collegeInfoTableView.dataSource = self;
    self.collegeInfoTableView.delegate = self;
    self.collegeInfoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.collegeInfoTableView.separatorColor =
    [UIColor grayColor];
    [self.view addSubview:self.collegeInfoTableView];
}


#pragma mark - UITableViewDataSource

// 返回表格分区数，默认返回1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SJCollegeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJCollegeTableViewCell"]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    if (cell == nil) {
        cell = (SJCollegeTableViewCell *)[[NSBundle mainBundle] loadNibNamed:@"SJCollegeTableViewCell" owner:self options:nil][0];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.collegeCellNameCN.text = @"学院简介";
            cell.collegeCellNameEN.text = @"COLLEGE INTRODUCTION";
            [cell.collegeCellBg setImage:[UIImage imageNamed:@"index_college_icon_1"]];
            break;
        case 1:
            cell.collegeCellNameCN.text = @"名师荟萃";
            cell.collegeCellNameEN.text = @"MENTOR TEAM";
            [cell.collegeCellBg setImage:[UIImage imageNamed:@"index_college_icon_2"]];
            break;
        case 2:
            cell.collegeCellNameCN.text = @"学员风采";
            cell.collegeCellNameEN.text = @"STUDENT STYLE";
            [cell.collegeCellBg setImage:[UIImage imageNamed:@"index_college_icon_3"]];
            break;
        case 3:
            cell.collegeCellNameCN.text = @"教学环境";
            cell.collegeCellNameEN.text = @"TEACHING ENVIRONMENT";
            [cell.collegeCellBg setImage:[UIImage imageNamed:@"index_college_icon_4"]];
            break;
        case 4:
            cell.collegeCellNameCN.text = @"联系我们";
            cell.collegeCellNameEN.text = @"CONTACT US";
            [cell.collegeCellBg setImage:[UIImage imageNamed:@"index_college_icon_5"]];
            break;
        default:
            break;
    }
    [cell.contentView setFrame:cell.frame];
    return cell;
}


// @required
// 提供tableView中的分区中的数据的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_collegeInfoList count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * url = @"";
    switch (indexPath.row) {
        case 0:
            //学院简介
            url = @"http://ztjyvip.com/ztjyxy/index_3.aspx";
            break;
        case 1:
            //名师荟萃
            url = @"http://ztjyvip.com/szzr/index_7.aspx";
            break;
        case 2:
            //学员风彩
            url = @"http://ztjyvip.com/hyln/list_14.aspx";
            break;
        case 3:
            //教学环境
            url = @"https://mp.weixin.qq.com/s/dLMUTENaXuop2WfSJYOS4Q";
            break;
        case 4:
            //联系我们
            url = @"http://u5041183.viewer.maka.im/pcviewer/8R5YDRYT";
            break;
        default:
            break;
    }
    
    ATJWebViewController *webVC = [[ATJWebViewController alloc] init];
    [webVC loadWebURLSring:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

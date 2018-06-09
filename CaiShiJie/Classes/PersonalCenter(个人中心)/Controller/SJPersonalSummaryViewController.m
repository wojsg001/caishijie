//
//  SJPersonalSummaryViewController.m
//  CaiShiJie
//
//  Created by user on 16/9/29.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonalSummaryViewController.h"
#import "UIColor+helper.h"
#import "SJPersonalSummaryOneCell.h"
#import "SJPersonalSummaryTwoCell.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import <BlocksKit/NSArray+BlocksKit.h>
#import "SJhttptool.h"

@interface SJPersonalSummarySectionView ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLineWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLineWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineHeightConstraint;

@end

@implementation SJPersonalSummarySectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.leftLineWidthConstraint.constant = 0.5;
    self.rightLineWidthConstraint.constant = 0.5;
    self.topLineHeightConstraint.constant = 0.5;
}

- (void)setDic:(NSDictionary *)dic {
    if (_dic != dic) {
        _dic = dic;
    }
    _iconImageView.image = [UIImage imageNamed:_dic[@"icon"]];
    _titleLabel.text = _dic[@"title"];
}

@end

@interface SJPersonalSummaryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) NSArray *staticArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *dataTwoArray;

@end

@implementation SJPersonalSummaryViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self initData];
    [self setupTableView];
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadSummaryData];
}

- (void)initData {
    self.sectionArray = @[@{@"icon":@"intro_icon_1", @"title":@"基本信息"},@{@"icon":@"intro_icon_2", @"title":@"擅长领域"}];
    self.staticArray = @[@"所属机构", @"从业资格证", @"从业年限", @"所在城市", @"个人简介",];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
}

- (void)loadSummaryData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/getbyteacher?userid=%@", HOST, self.target_id];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        if ([respose[@"status"] isEqualToString:@"1"]) {
            [self handleSummaryData:respose[@"data"]];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

- (void)handleSummaryData:(NSDictionary *)dic {
    NSString *institution_name = [NSString stringWithFormat:@"%@",dic[@"institution_name"]];
    if ([institution_name isEqualToString:@"<null>"] || [institution_name isEqualToString:@""]) {
        [self.dataArray addObject:@"暂无"];
    } else {
        [self.dataArray addObject:[NSString stringWithFormat:@"%@", institution_name]];
    }
    
    NSString *certificate = [NSString stringWithFormat:@"%@",dic[@"certificate"]];
    if ([certificate isEqualToString:@"<null>"] || [certificate isEqualToString:@""]) {
        [self.dataArray addObject:@"暂无"];
    } else {
        [self.dataArray addObject:[NSString stringWithFormat:@"%@", certificate]];
    }
    
    NSString *investment_year = [NSString stringWithFormat:@"%@",dic[@"investment_year"]];
    if ([investment_year isEqualToString:@"<null>"] || [investment_year isEqualToString:@""]) {
        [self.dataArray addObject:@"暂无"];
    } else {
        [self.dataArray addObject:[NSString stringWithFormat:@"%@", investment_year]];
    }
    
    if (dic[@"address"] == nil || [dic[@"address"] isKindOfClass:[NSString class]]) {
        [self.dataArray addObject:@"暂无"];
    } else {
        if (dic[@"address"][@"city"] != nil && ![dic[@"address"][@"city"] isEqualToString:@""]) {
            [self.dataArray addObject:[NSString stringWithFormat:@"%@", dic[@"address"][@"city"]]];
        } else if (dic[@"address"][@"province"] != nil && ![dic[@"address"][@"province"] isEqualToString:@""]) {
            [self.dataArray addObject:[NSString stringWithFormat:@"%@", dic[@"address"][@"province"]]];
        } else {
            [self.dataArray addObject:@"暂无"];
        }
    }
    
    NSString *introduction = [NSString stringWithFormat:@"%@",dic[@"introduction"]];
    if ([introduction isEqualToString:@"<null>"] || [introduction isEqualToString:@""]) {
        [self.dataArray addObject:@"暂无"];
    } else {
        [self.dataArray addObject:[NSString stringWithFormat:@"%@", introduction]];
    }
    
    NSString *field = [NSString stringWithFormat:@"%@", dic[@"field"]];
    if (dic[@"field"] != nil && ![field isEqualToString:@""]) {
        self.dataTwoArray = [field componentsSeparatedByString:@","];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.staticArray.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SJPersonalSummaryOneCell *cell = [SJPersonalSummaryOneCell cellWithTableView:tableView];
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            cell.preservesSuperviewLayoutMargins = NO;
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        cell.text = self.staticArray[indexPath.row];
        if (self.dataArray.count) {
            cell.content = self.dataArray[indexPath.row];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        SJPersonalSummaryTwoCell *cell = [SJPersonalSummaryTwoCell cellWithTableView:tableView];
        if (self.dataTwoArray.count) {
            cell.contentArray = self.dataTwoArray;
        }
        return cell;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.dataArray.count) {
            return [SJPersonalSummaryOneCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                SJPersonalSummaryOneCell *cell = (SJPersonalSummaryOneCell *)sourceCell;
                if (self.dataArray.count) {
                    [cell setContent:self.dataArray[indexPath.row]];
                }
                
            }];
        } else {
            return 34;
        }
        
    } else {
        NSInteger count = self.dataTwoArray.count;
        return 57*(count%3==0?count/3:count/3+1);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *tmpView = [[UIView alloc] init];
    tmpView.backgroundColor = [UIColor clearColor];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SJPersonalCenterUI" owner:nil options:nil];
    SJPersonalSummarySectionView *sectionView = [nib bk_match:^BOOL(id obj) {
        return [obj isKindOfClass:[SJPersonalSummarySectionView class]];
    }];
    sectionView.dic = self.sectionArray[section];
    [tmpView addSubview:sectionView];
    [sectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(34);
    }];
    return tmpView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

@end

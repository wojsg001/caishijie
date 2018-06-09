//
//  SJsearchController.m
//  CaiShiJie
//
//  Created by user on 16/5/10.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJsearchController.h"
#import "UIImage+SJimage_UIcolor.h"
#import "ZYPinYinSearch.h"
#import "ChineseString.h"
#import "SJsearchCell.h"
#import "SJhttptool.h"
#import "MBProgressHUD+MJ.h"
#import "NSString+SJMD5.h"
#import "StockKeyboard.h"
#import "SJStockDetailContentViewController.h"

@interface SJsearchController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *tablview;
@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/
@property (nonatomic, strong) NSMutableArray *selectedarr;
@property (weak, nonatomic) IBOutlet UIView *resultView;

@end

@implementation SJsearchController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"股票查询";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSMutableArray*)searchDataSource {
    
    if (_searchDataSource == nil) {
        _searchDataSource = [NSMutableArray array];
    }
    
    return _searchDataSource;
}

- (NSMutableArray *)selectedarr {
    
    if (_selectedarr == nil) {
        _selectedarr = [NSMutableArray array];
    }
    
    return _selectedarr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTableView];
    [self setSearchbar];
}

- (void)setSearchbar {
    
    self.resultView.layer.borderColor = RGB(227, 227, 227).CGColor;
    self.resultView.layer.borderWidth = 0.5f;
    
    self.searchbar.backgroundImage =[UIImage imageWithColor:RGB(239, 239, 243)];
    self.searchbar.delegate =self;
    UITextField *searchTextField = [[[self.searchbar.subviews firstObject] subviews] lastObject];
    searchTextField.layer.borderColor = RGB(227, 227, 227).CGColor
    ;
    searchTextField.layer.borderWidth = 0.5f;
    searchTextField.layer.cornerRadius = 4.0f;
    searchTextField.layer.masksToBounds = YES;
    
    StockKeyboard *keyboard = [[StockKeyboard alloc] initWithKeyboardType:KeyboardTypeNumber andTextFieldView:searchTextField];
    keyboard.confirmBlock = ^() {
        //SJLog(@"点击了确定按钮");
    };
    searchTextField.inputView = keyboard;
}

- (void)setTableView {
    self.tablview.delegate =self;
    self.tablview.dataSource =self;
    
    UINib *nib =[UINib nibWithNibName:@"SJsearchCell"bundle:nil];
    [self.tablview registerNib:nib forCellReuseIdentifier:@"cell"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SJsearchCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    [cell.btn addTarget:self action:@selector(tianjia:) forControlEvents:UIControlEventTouchUpInside];
    cell.btn.tag =indexPath.row +1;
    
    if (_searchDataSource.count>indexPath.row) {
        
        NSDictionary *celldata =_searchDataSource[indexPath.row];
        
        if ([self.selectedarr containsObject:[NSString stringWithFormat:@"%@",celldata[@"name"]]]) {
            cell.btn.imageView.image = [UIImage imageNamed:@"stock_add_icon_h"];
            
        }else{
            cell.btn.imageView.image = [UIImage imageNamed:@"stock_add_icon_n"];
        }
        cell.name.text = celldata[@"name"];
        cell.number.text = [NSString stringWithFormat:@"%@",celldata[@"code"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = self.searchDataSource[indexPath.row];
    NSString *code = dict[@"code"];
    NSString *type = dict[@"type"];
    NSString *name = dict[@"name"];
    SJStockDetailContentViewController *stockDetailVC =[[SJStockDetailContentViewController alloc] init];
    stockDetailVC.type = type;
    stockDetailVC.code = code;
    stockDetailVC.name = name;
    [self.navigationController pushViewController:stockDetailVC animated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self.searchDataSource removeAllObjects];
    
    NSString *code = searchBar.text;
    NSString *url = [NSString stringWithFormat:@"%@/mobile/search/stock",HOST];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:code,@"code",@"1",@"pageindex",@"10",@"pageindex", nil];
    [SJhttptool GET:url paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSDictionary *datadic =respose[@"data"];
            // 总数
            // NSString *count =datadic[@"count"];
            NSArray *stock =datadic[@"stock"];
            for (NSDictionary *dict in stock) {
                [self.searchDataSource addObject:dict];
                [self.tablview reloadData];
            }
            
        }else{
            [MBProgressHUD showError:@"请求失败"];
        }
        
    } failure:^(NSError *error) {
        
        //SJLog(@"%@",error);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self.searchDataSource removeAllObjects];
    
    NSString *code = searchBar.text;
    NSString *url = [NSString stringWithFormat:@"%@/mobile/search/stock",HOST];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:code,@"code",@"1",@"pageindex",@"10",@"pageindex", nil];
    [SJhttptool GET:url paramers:dic success:^(id respose) {
        //SJLog(@"%@",respose);
       
       if ([respose[@"states"] isEqualToString:@"1"]) {
            NSDictionary *datadic =respose[@"data"];
            //总数
            //NSString *count =datadic[@"count"];
            NSArray *stock =datadic[@"stock"];
            for (NSDictionary *dict in stock) {
                [self.searchDataSource addObject:dict];
                [self.tablview reloadData];
            }
            
        }else{
            
            [MBProgressHUD showError:@"请求失败"];
        }
     
    } failure:^(NSError *error) {
        
        SJLog(@"%@",error);
    }];
}

-(void)tianjia:(UIButton *)btn{
    [btn setImage:[UIImage imageNamed:@"stock_add_icon_h"] forState:UIControlStateNormal];
    NSDictionary *dicct = self.searchDataSource[btn.tag-1];
    NSString *name = dicct[@"name"];
    if ([self.selectedarr containsObject:name]) {
       
        [MBProgressHUD showSuccess:@"已成功加入自选股"];
        return;
        
    }else{
      
        [MBProgressHUD showMessage:@"正在加入中。。。"];
       
        [self.selectedarr addObject:name];
        
        NSString *urlstr = [NSString stringWithFormat:@"%@/mobile/stock/addstock",HOST];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *user_id = [d valueForKey:kUserid];
        NSString *auth_key = [d valueForKey:kAuth_key];
        NSDate *date = [NSDate date];
        NSString *datestr = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
        
        
        NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
        
        NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",dicct[@"code"], @"code", nil];
        
        [SJhttptool POST:urlstr paramers:paramers success:^(id respose) {
            if ([respose[@"states"] isEqualToString:@"1"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"加入成功"];
                
            }else{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"加入失败"];
            }
            
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"加入失败"];
        }];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

@end

//
//  SJEditViewController.m
//  CaiShiJie
//
//  Created by user on 16/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJEditViewController.h"
#import "SJEditcell.h"
#import "UIImage+SJimage_UIcolor.h"
#import "SJsearchController.h"
#import "SJhttptool.h"
#import "SJMySelectedStockModel.h"
#import "SJToken.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "UIColor+helper.h"

@interface SJEditViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SJNoWifiViewDelegate>{
    
    NSString *_codes;
    NSDictionary *dict;
}

@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *selectedarr;
@property (nonatomic, strong) NSMutableArray *attentionList;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *searchdataSource;
@property (assign, nonatomic) BOOL isSearch;

@end

@implementation SJEditViewController

- (NSMutableArray *)attentionList {
    if (!_attentionList) {
        _attentionList = [NSMutableArray array];
    }
    return _attentionList;
}

- (NSMutableArray *)selectedarr{
    
    if (_selectedarr ==nil) {
        
        _selectedarr =[NSMutableArray array];
    }
    return _selectedarr;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
    
}
- (NSMutableArray *)searchdataSource {
    if (_searchdataSource == nil) {
        _searchdataSource = [NSMutableArray array];
    }
    
    return _searchdataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _codes = [NSString string];
    _isSearch = NO;
  
    self.searchbar.backgroundImage = [UIImage imageWithColor:RGB(239, 239, 244)];
    self.searchbar.delegate = self;
    UITextField *searchTextField = [[[self.searchbar.subviews firstObject] subviews] lastObject];
    searchTextField.layer.borderColor = RGB(227, 227, 227).CGColor
    ;
    searchTextField.layer.borderWidth = 0.5f;
    searchTextField.layer.cornerRadius = 4.0f;
    searchTextField.layer.masksToBounds = YES;
    
    self.navigationItem.title = @"编辑";
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stock_del_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(deletedata)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self.tableview setEditing:YES animated:YES];
    [self.tableview setAllowsSelectionDuringEditing:YES];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    
    UINib *nib = [UINib nibWithNibName:@"SJEditcell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"cell"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 加载数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loaddata];
}

- (void)loaddata{
    NSString *url = [NSString stringWithFormat:@"%@/mobile/stock/getbyuserid", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *param = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"pageindex":@"1",@"pagesize":@"20"};
    
    [SJhttptool GET:url paramers:param success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        //SJLog(@"测试%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJMySelectedStockModel objectArrayWithKeyValuesArray:respose[@"data"][@"attention"]];
            [self.attentionList removeAllObjects];
            [self.dataArr removeAllObjects];
            [self.tableview reloadData];
            if (tmpArray.count) {
                self.noDataView.hidden = YES;
                [self.attentionList addObjectsFromArray:tmpArray];
                [self loadSinnaStock:tmpArray];
            } else {
                self.noDataView.hidden = NO;
            }
            
        } else {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

- (void)loadSinnaStock:(NSArray *)array {
    NSMutableString *stockStr = [NSMutableString string];
    for (SJMySelectedStockModel *model in array) {
        [stockStr appendString:@"s_"];
        [stockStr appendString:model.type];
        [stockStr appendString:model.code];
        [stockStr appendString:@","];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@", stockStr];
    SJLog(@"%@", urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:encode];
        
        NSArray *matches = [self matcheInString:obj regularExpressionWithPattern:@"s_([a-z]{2})([0-9]{6})=\"(\\S{1,})\""];
        for (NSTextCheckingResult *match in matches) {
            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
            
            NSString *tmpStrOne = [obj substringWithRange:match.range];
            NSArray *tmpArrayOne = [tmpStrOne componentsSeparatedByString:@"="];
            
            NSString *tmpStrTwo = tmpArrayOne[1];
            tmpStrTwo = [tmpStrTwo stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *tmpArrayTwo = [tmpStrTwo componentsSeparatedByString:@","];
            tmpDic[@"name"] = tmpArrayTwo[0];
            tmpDic[@"trade"] = tmpArrayTwo[1];
            tmpDic[@"changepercent"] = tmpArrayTwo[3];
            
            NSString *tmpStrThree = tmpArrayOne[0];
            tmpStrThree = [tmpStrThree stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            tmpDic[@"code"] = [tmpStrThree substringWithRange:NSMakeRange(4, 6)];
            tmpDic[@"code2"] = [tmpStrThree substringWithRange:NSMakeRange(2, 8)];
            
            [self.dataArr addObject:tmpDic];
            [self.tableview reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:string options:0 range:range];
    return matches;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearch) {
        return self.searchdataSource.count;
    } else {
        return self.dataArr.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SJEditcell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    if (_isSearch) {
        dict = self.searchdataSource[indexPath.row];
        cell.namelable.text = dict[@"name"];
        NSString *price = [NSString stringWithFormat:@"%@", dict[@"currentPrice"]];
        cell.price.text =[NSString stringWithFormat:@"%.2f",[price floatValue]];
        cell.code.text =[NSString stringWithFormat:@"%@",dict[@"code2"]];
    } else {
        dict = self.dataArr[indexPath.row];
        cell.namelable.text = dict[@"name"];
        NSString *price = [NSString stringWithFormat:@"%@", dict[@"trade"]];
        cell.price.text = [NSString stringWithFormat:@"%.2f",[price floatValue]];
        cell.code.text = [NSString stringWithFormat:@"%@",dict[@"code"]];
    }
    
    if ([self.selectedarr containsObject:[NSString stringWithFormat:@"%@",dict[@"code"]]]) {
        cell.imageview.image = [UIImage imageNamed:@"stock_del"];
    } else {
        cell.imageview.image = [UIImage imageNamed:@"stock_sosuo"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJEditcell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    NSString *codestr = cell1.code.text;
    
    if ([self.selectedarr containsObject:codestr]) {
        cell1.imageview.image =[UIImage imageNamed:@"stock_sosuo"];
        [self.selectedarr removeObject:codestr];
    } else {
        cell1.imageview.image =[UIImage imageNamed:@"stock_del"];
        [self.selectedarr addObject:codestr];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //允许移动
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSInteger fromrow =[sourceIndexPath row];
    NSInteger torow =[destinationIndexPath row];
    if (_isSearch) {
        id object = [self.searchdataSource objectAtIndex:fromrow];
        [self.searchdataSource removeObjectAtIndex:fromrow];
        [self.searchdataSource insertObject:object atIndex:torow];
        
    } else {
        id object1 = [self.dataArr objectAtIndex:fromrow];
        [self.dataArr removeObjectAtIndex:fromrow];
        [self.dataArr insertObject:object1 atIndex:torow];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 0.5)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"#e3e3e3" withAlpha:1];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (void)deletedata {
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/stock/removestock",HOST];
    SJToken *instance = [SJToken sharedToken];
    
    if (self.selectedarr.count == 1) {
        _codes = self.selectedarr[0];
    } else if (!self.selectedarr.count) {
        [MBProgressHUD showError:@"未选中删除的股票"];
        return;
    } else {
        for (NSString *codestring in self.selectedarr) {
            NSString *Code = [NSString stringWithFormat:@"%@,",codestring];
           _codes = [_codes stringByAppendingString:Code];
            SJLog(@"%@",_codes);
        }
    }
    
    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:instance.userid,@"userid",instance.time,@"time",instance.token,@"token",_codes,@"code", nil];
    [SJhttptool POST:urlStr paramers:paramers success:^(id respose) {
       SJLog(@"%@",respose);
       if ([respose[@"states"] isEqualToString:@"1"]) {
           [self loaddata];
       } else {
           [MBHUDHelper showWarningWithText:respose[@"data"]];
       }
     
   } failure:^(NSError *error) {
       [MBHUDHelper showWarningWithText:error.localizedDescription];
   }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchdataSource removeAllObjects];
    _isSearch = YES;
   
    NSString *codes =searchBar.text;
    SJLog(@"%@",codes);

    NSString *url =[NSString stringWithFormat:@"%@/mobile/stock/stockmy",HOST];
    SJToken *instance = [SJToken sharedToken];

    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:instance.userid,@"userid",instance.time,@"time",instance.token,@"token",codes,@"code",@"1",@"pageindex",@"10",@"pagesize", nil];

    [SJhttptool GET:url paramers:paramers success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"]) {
            NSDictionary *datadic =respose[@"data"];
            
            id value =datadic[@"stock"];
            if ([value isKindOfClass:[NSString class]]) {
                
                [MBProgressHUD hideHUD];
                [self.tableview reloadData];
                return ;
            } else {
                
                NSArray *stock =datadic[@"stock"];
                for (NSDictionary *dict1 in stock) {
                    [self.searchdataSource addObject:dict1];
                    
                    [self.tableview reloadData];
                    [MBProgressHUD hideHUD];
                }
            }
        } else {
            [MBProgressHUD showError:@"请求失败"];
            [MBProgressHUD hideHUD];
        }
        
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length==0) {
        _isSearch =NO;
        [self loaddata];
        [MBProgressHUD hideHUD];
        
    } else {
        
        [_searchdataSource removeAllObjects];
        _isSearch =YES;
        
        NSString *codes = searchBar.text;
        SJLog(@"%@",codes);
        
        NSString *url = [NSString stringWithFormat:@"%@/mobile/stock/stockmy",HOST];
        SJToken *instance = [SJToken sharedToken];
        
        NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:instance.userid,@"userid",instance.time,@"time",instance.token,@"token",codes,@"code",@"1",@"pageindex",@"10",@"pagesize", nil];
        
        [SJhttptool GET:url paramers:paramers success:^(id respose) {
            if ([respose[@"states"] isEqualToString:@"1"]) {
                NSDictionary *datadic = respose[@"data"];
                
                id value = datadic[@"stock"];
                if ([value isKindOfClass:[NSString class]]) {
                    [MBProgressHUD hideHUD];
                    [self.tableview reloadData];
                    return ;
                } else {
                    NSArray *stock =datadic[@"stock"];
                    for (NSDictionary *dict1 in stock) {
                        [self.searchdataSource addObject:dict1];
                        [self.tableview reloadData];
                        [MBProgressHUD hideHUD];
                    }
                }
                
            } else {
                [MBProgressHUD showError:@"请求失败"];
                [MBProgressHUD hideHUD];
            }
            
        } failure:^(NSError *error) {
            [MBHUDHelper showWarningWithText:error.localizedDescription];
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [self loaddata];
}

@end

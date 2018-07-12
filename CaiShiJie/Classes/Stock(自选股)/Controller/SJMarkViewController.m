//
//  SJMarkViewController.m
//  CaiShiJie
//
//  Created by user on 18/5/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMarkViewController.h"
#import "UIImage+SJimage_UIcolor.h"
#import "SJFirstsectionCollectionCell.h"
#import "SJSecondsectionCollectionCell.h"
#import "SJThreesectionCollectionCell.h"
#import "SJHeadcollectvc.h"
#import "SJRoseController.h"
#import "SJsearchController.h"
#import "AFNetworking.h"
#import "SJhttptool.h"
#import "SJStockDetailContentViewController.h"

@interface SJMarkViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SJHeadcollectvcdelegate,UISearchBarDelegate,SJNoWifiViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property (nonatomic, strong) NSArray *arr4;
@property (nonatomic, strong) NSArray *arr5;
@property (nonatomic, strong) NSArray *arr6;
//涨幅榜
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, assign) BOOL isNetwork;

@end

@implementation SJMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.isNetwork = YES;
    [self setUpSearchBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"updatamark" object:nil];
    
    self.collectionview.dataSource = self;
    self.collectionview.delegate = self;
    self.collectionview.backgroundColor = [UIColor whiteColor];
    [self.collectionview registerNib:[UINib nibWithNibName:@"SJFirstsectionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell1"];
    [self.collectionview registerNib:[UINib nibWithNibName:@"SJSecondsectionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell2"];
    [self.collectionview registerNib:[UINib nibWithNibName:@"SJThreesectionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell3"];
    
    //注册是分组头还是分组foot
    [self.collectionview registerNib:[UINib nibWithNibName:@"SJHeadcollectvc" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headvc"];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshNetwork];
}

//刷新
- (void)loadData {
    [self loadData1];
    [self loadData2];
    [self loaddata3];
    [self loaddata6];
    [self loaddata8];
}

- (void)setUpSearchBar {
    _searchBar.keyboardType = UIKeyboardAppearanceDefault;
    _searchBar.placeholder = @"搜索";
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
}

//上证指数
- (void)loaddata6 {
    NSString *urlStr = @"http://hq.sinajs.cn/list=s_sh000001";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        SJLog(@"JSON: %@", obj);
        NSArray *arr1 = [obj componentsSeparatedByString:@"="];
        NSString *str1 = [arr1 objectAtIndex:1];
        self.arr6 = [str1 componentsSeparatedByString:@","];
        
        [self.collectionview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"--%@",error);
    }];
}

//创业板指
- (void)loadData1 {
    NSString *urlStr = @"http://hq.sinajs.cn/list=s_sz399006";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        // SJLog(@"JSON: %@", obj);
        NSArray *arr1 = [obj componentsSeparatedByString:@"="];
        NSString *str1 = [arr1 objectAtIndex:1];
        self.arr4 =[str1 componentsSeparatedByString:@","];
        
        [self.collectionview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"--%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        self.isNetwork = NO;
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

//深证成指
- (void)loadData2 {
    NSString *urlStr = @"http://hq.sinajs.cn/list=s_sz399001";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        // SJLog(@"JSON: %@", obj);
        
        NSArray *arr1 = [obj componentsSeparatedByString:@"="];
        NSString *str1 = [arr1 objectAtIndex:1];
        self.arr5 =[str1 componentsSeparatedByString:@","];
        
        [self.collectionview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"--%@",error);
    }];
}
//涨幅榜
- (void)loaddata3 {
    NSString *urlStr = @"http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page=1&num=10&sort=changepercent&asc=0&node=hs_a&symbol=&_s_r_a=sort";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        
        NSString *searchText = obj;
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"[0-9]{2}:[0-9]{2}:[0-9]{2}\"" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *results = [regex matchesInString:searchText options:0 range:NSMakeRange(0, searchText.length)];
        
        if (results.count) {
            NSMutableArray *arrM = [NSMutableArray array];
            for (int i = 0; i < results.count; i++) {
                NSTextCheckingResult *result = results[i];
                NSString *str = [searchText substringWithRange:result.range];
                
                [arrM addObject:str];
            }
            
            for (int i = 0; i < arrM.count; i++) {
                searchText = [searchText stringByReplacingOccurrencesOfString:arrM[i] withString:@"11"];
            }
        }
        
        NSString *validString = [searchText stringByReplacingOccurrencesOfString:@"(\\w+)\\s*:([^a-zA-Z0-9_.:-]+)" withString:@"\"$1\":$2" options:NSRegularExpressionSearch range:NSMakeRange(0, [searchText length])];
        //SJLog(@"validString---%@",validString);
        
        NSString *validString2 = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])(\\w+)\\s*:" withString:@"$1\"$2\":" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
        //SJLog(@"validString%@",validString2);
        
        NSData *data =[validString2 dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *arr7 =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        //SJLog(@"--涨跌幅--%@",arr7);
        
        self.arr = arr7;
        [self.collectionview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"--%@",error);
    }];
}
//热门行业
- (void)loaddata8 {
    
    NSString *urlStr = [NSString stringWithFormat:@"http://vip.stock.finance.sina.com.cn/q/view/newSinaHy.php"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //请求时提交的数据格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //服务器返回的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 二进制数据
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *obj = [[NSString alloc] initWithData:responseObject encoding:enc];
        //SJLog(@"JSONsssss: %@", obj);
        NSArray *arrs = [obj componentsSeparatedByString:@"="];
        NSString *Str = [arrs objectAtIndex:1];
        SJLog(@"热门行业---%@",Str);
        NSData *data1 = [Str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableLeaves error:nil];
        // SJLog(@"tmpDict---%@",dic1);
        // 玻璃行业
        self.dic = dic1;
        [self.collectionview reloadData];
        /*
         NSString *string2 = self.dic[@"new_cmyl"];
         
         SJLog(@"%@",string2);
         NSArray *hotdataarr1 =[string2 componentsSeparatedByString:@","];
         for (int i=0; i<hotdataarr1.count; i++) {
         
         NSString *str = hotdataarr1[i];
         
         SJLog(@"SYT%i  %@",i,str);
         }
         */
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SJLog(@"--%@",error);
    }];
}


#pragma markcollectiondelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section==0) {
        return 3;
    } else if (section==1) {
        return 6;
    } else {
        return self.arr.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SJFirstsectionCollectionCell *cell1 =[collectionView dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            NSString *namestr = [NSString stringWithFormat:@"%@",[_arr4 objectAtIndex:0]];
            cell1.name.text = [namestr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            cell1.zhishu.text = [NSString stringWithFormat:@"%@",_arr4[1]];
            NSString *zhang = [NSString stringWithFormat:@"%@",_arr4[2]];
            float number = [zhang floatValue];
            cell1.zhangfu1.text = [NSString stringWithFormat:@"%.2f",number];
            
            if (number > 0) {
                //涨幅
                cell1.zhangfu1.text = [NSString stringWithFormat:@"+%@",cell1.zhangfu1.text];
                //百分比
                NSString *zhangfu = [NSString stringWithFormat:@"%@",_arr4[3]];
                NSString *zhang2 = [zhangfu stringByAppendingString:@"%"];
                cell1.zhangfu2.text = [NSString stringWithFormat:@"+%@",zhang2];
                cell1.zhishu.textColor=RGB(217, 67, 50);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon2"];
            } else if (number == 0) {
                //涨幅
                cell1.zhangfu1.text = [NSString stringWithFormat:@"+%@",cell1.zhangfu1.text];
                //百分比
                NSString *zhangfu = [NSString stringWithFormat:@"%@",_arr4[3]];
                NSString *zhang2 = [zhangfu stringByAppendingString:@"%"];
                cell1.zhangfu2.text = [NSString stringWithFormat:@"+%@",zhang2];
                cell1.zhishu.textColor = RGB(217, 67, 50);
                cell1.imgvc.image = [UIImage imageNamed:@"stock_market_icon2"];
            } else {
                 NSString *zhangfu = [NSString stringWithFormat:@"%@",_arr4[3]];
                 cell1.zhangfu2.text = [zhangfu stringByAppendingString:@"%"];
                 cell1.zhishu.textColor = RGB(34, 172, 56);
                 cell1.imgvc.image = [UIImage imageNamed:@"stock_market_icon"];
            }
        } else if(indexPath.row == 1) {
            NSString *namestr = [NSString stringWithFormat:@"%@",[_arr5 objectAtIndex:0]];
            cell1.name.text = [namestr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            cell1.zhishu.text = [NSString stringWithFormat:@"%@",_arr5[1]];
            NSString *zhang = [NSString stringWithFormat:@"%@",_arr5[2]];
            float number = [zhang floatValue];
            cell1.zhangfu1.text = [NSString stringWithFormat:@"%.2f",number];

            if (number > 0) {
                //涨幅
                cell1.zhangfu1.text =[NSString stringWithFormat:@"+%@",cell1.zhangfu1.text];
                //百分比
                NSString *zhangfu =[NSString stringWithFormat:@"%@",_arr5[3]];
                NSString *zhang2 =[zhangfu stringByAppendingString:@"%"];
                cell1.zhangfu2.text =[NSString stringWithFormat:@"+%@",zhang2];
                cell1.zhishu.textColor=RGB(217, 67, 50);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon2"];
            } else if (number == 0) {
                //涨幅
                cell1.zhangfu1.text =[NSString stringWithFormat:@"+%@",cell1.zhangfu1.text];
                //百分比
                NSString *zhangfu =[NSString stringWithFormat:@"%@",_arr5[3]];
                NSString *zhang2 =[zhangfu stringByAppendingString:@"%"];
                cell1.zhangfu2.text =[NSString stringWithFormat:@"+%@",zhang2];
                cell1.zhishu.textColor=RGB(217, 67, 50);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon2"];
            } else {
                NSString *zhangfu =[NSString stringWithFormat:@"%@",_arr5[3]];
                cell1.zhangfu2.text =[zhangfu stringByAppendingString:@"%"];
                cell1.zhishu.textColor =RGB(34, 172, 56);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon"];
            }
        } else {
            NSString *namestr = [NSString stringWithFormat:@"%@",[_arr6 objectAtIndex:0]];
            cell1.name.text = [namestr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *Zhishu = [NSString stringWithFormat:@"%@",_arr6[1]];
            float m = [Zhishu floatValue];
            cell1.zhishu.text = [NSString stringWithFormat:@"%.2f",m];
            NSString *zhang = [NSString stringWithFormat:@"%@",_arr6[2]];
            float number = [zhang floatValue];
            cell1.zhangfu1.text = [NSString stringWithFormat:@"%.2f",number];

            if (number > 0) {
                //涨幅
                cell1.zhangfu1.text = [NSString stringWithFormat:@"+%@",cell1.zhangfu1.text];
                //百分比
                NSString *zhangfu = [NSString stringWithFormat:@"%@",_arr6[3]];
                NSString *zhang2 = [zhangfu stringByAppendingString:@"%"];
                cell1.zhangfu2.text =[NSString stringWithFormat:@"+%@",zhang2];
                cell1.zhishu.textColor=RGB(217, 67, 50);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon2"];
            } else if (number == 0) {
                //涨幅
                cell1.zhangfu1.text =[NSString stringWithFormat:@"+%@",cell1.zhangfu1.text];
                //百分比
                NSString *zhangfu =[NSString stringWithFormat:@"%@",_arr6[3]];
                NSString *zhang2 =[zhangfu stringByAppendingString:@"%"];
                cell1.zhangfu2.text =[NSString stringWithFormat:@"+%@",zhang2];
                cell1.zhishu.textColor=RGB(217, 67, 50);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon2"];
            } else {
                NSString *zhangfu =[NSString stringWithFormat:@"%@",_arr6[3]];
                cell1.zhangfu2.text =[zhangfu stringByAppendingString:@"%"];
                cell1.zhishu.textColor =RGB(34, 172, 56);
                cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon"];
            }
        }

        return cell1;
    } else if (indexPath.section == 1) {
        SJSecondsectionCollectionCell *cell2 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell2.left.constant = 10;
            cell2.right.constant = 0;
            cell2.bottomview.hidden = NO;
            NSString *string  = _dic[@"new_blhy"];
            NSArray *dataArr = [string componentsSeparatedByString:@","];
            
            cell2.name.text = dataArr[1];
            NSString *zhangfu = [NSString stringWithFormat:@"%@",dataArr[5]];
            float n = [zhangfu floatValue];
            NSString *zhangfu2 = [NSString stringWithFormat:@"%.2f",n];
            cell2.zhangfu.text = [zhangfu2 stringByAppendingString:@"%"];
            if (n>0||n==0) {
                cell2.zhangfu.textColor =RGB(254, 63, 77);
            } else {
                cell2.zhangfu.textColor =RGB(34, 172, 56);
            }
         
            cell2.stockname.text = dataArr[12];
            NSString *price1 = [NSString stringWithFormat:@"%@",dataArr[11]];
            float price2 = [price1 floatValue];
            
            NSString *percent1 = [NSString stringWithFormat:@"%@",dataArr[9]];
            float percent2 = [percent1 floatValue];
            
            if (price2>0||price2 == 0) {
                NSString *price3 = [NSString stringWithFormat:@"+%.2f",price2];
                cell2.price.text = price3;
                NSString *percent3 =[NSString stringWithFormat:@"+%.2f",percent2];
                cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
            } else {
                NSString *price3 =[NSString stringWithFormat:@"%.2f",price2];
                cell2.price.text =price3;
                NSString *percent3 =[NSString stringWithFormat:@"%.2f",percent2];
                cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
            }
        } else if (indexPath.row == 1) {
            cell2.left.constant = 0;
            cell2.right.constant = 0;
            cell2.bottomview.hidden = NO;
            NSString *string  = _dic[@"new_fzhy"];
            NSArray *dataArr = [string componentsSeparatedByString:@","];
            
            cell2.name.text = dataArr[1];
            NSString *zhangfu = [NSString stringWithFormat:@"%@",dataArr[5]];
            float n = [zhangfu floatValue];
            NSString *zhangfu2 = [NSString stringWithFormat:@"%.2f",n];
            cell2.zhangfu.text = [zhangfu2 stringByAppendingString:@"%"];
            if (n>0||n==0) {
                cell2.zhangfu.textColor =RGB(254, 63, 77);
            } else {
                cell2.zhangfu.textColor =RGB(34, 172, 56);
            }
            
            cell2.stockname.text = dataArr[12];
            NSString *price1 = [NSString stringWithFormat:@"%@",dataArr[11]];
            float price2 = [price1 floatValue];
            
            NSString *percent1 = [NSString stringWithFormat:@"%@",dataArr[9]];
            float percent2 = [percent1 floatValue];
            
            if (price2>0||price2==0) {
                NSString *price3 = [NSString stringWithFormat:@"+%.2f",price2];
                cell2.price.text = price3;
                NSString *percent3 = [NSString stringWithFormat:@"+%.2f",percent2];
                cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
            } else {
                NSString *price3 =[NSString stringWithFormat:@"%.2f",price2];
                cell2.price.text =price3;
                NSString *percent3 =[NSString stringWithFormat:@"%.2f",percent2];
                cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
            }
        } else if (indexPath.row==2){
            cell2.right.constant =10;
            cell2.left.constant =0;
            cell2.bottomview.hidden =NO;
            
            NSString *string  =_dic[@"new_dlhy"];
            NSArray *dataArr =[string componentsSeparatedByString:@","];
            
            cell2.name.text =dataArr[1];
            NSString *zhangfu =[NSString stringWithFormat:@"%@",dataArr[5]];
            float n =[zhangfu floatValue];
            NSString *zhangfu2 =[NSString stringWithFormat:@"%.2f",n];
            cell2.zhangfu.text =[zhangfu2 stringByAppendingString:@"%"];
            if (n>0||n==0) {
                cell2.zhangfu.textColor =RGB(254, 63, 77);
            } else {
                cell2.zhangfu.textColor =RGB(34, 172, 56);
            }
            
            cell2.stockname.text = dataArr[12];
            NSString *price1 = [NSString stringWithFormat:@"%@",dataArr[11]];
            float price2 = [price1 floatValue];
            NSString *percent1 = [NSString stringWithFormat:@"%@",dataArr[9]];
            float percent2 = [percent1 floatValue];
            
            if (price2>0||price2==0) {
                NSString *price3 = [NSString stringWithFormat:@"+%.2f",price2];
                cell2.price.text = price3;
                NSString *percent3 = [NSString stringWithFormat:@"+%.2f",percent2];
                cell2.pricepercent.text = [percent3 stringByAppendingString:@"%"];
            } else {
                NSString *price3 =[NSString stringWithFormat:@"%.2f",price2];
                cell2.price.text =price3;
                NSString *percent3 =[NSString stringWithFormat:@"%.2f",percent2];
                cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
            }
        } else {
            cell2.bottomview.hidden = YES;
            if (indexPath.row==3) {
                NSString *string = _dic[@"new_gthy"];
                NSArray *dataArr = [string componentsSeparatedByString:@","];
                
                cell2.name.text = dataArr[1];
                NSString *zhangfu = [NSString stringWithFormat:@"%@",dataArr[5]];
                float n = [zhangfu floatValue];
                NSString *zhangfu2 = [NSString stringWithFormat:@"%.2f",n];
                cell2.zhangfu.text = [zhangfu2 stringByAppendingString:@"%"];
                if (n>0||n==0) {
                    cell2.zhangfu.textColor =RGB(254, 63, 77);
                } else {
                    cell2.zhangfu.textColor =RGB(34, 172, 56);
                }
                
                cell2.stockname.text = dataArr[12];
                NSString *price1 = [NSString stringWithFormat:@"%@",dataArr[11]];
                float price2 = [price1 floatValue];
                
                NSString *percent1 = [NSString stringWithFormat:@"%@",dataArr[9]];
                float percent2 = [percent1 floatValue];
                
                if (price2>0||price2==0) {
                    NSString *price3 = [NSString stringWithFormat:@"+%.2f",price2];
                    cell2.price.text = price3;
                    NSString *percent3 = [NSString stringWithFormat:@"+%.2f",percent2];
                    cell2.pricepercent.text = [percent3 stringByAppendingString:@"%"];
                } else {
                    NSString *price3 = [NSString stringWithFormat:@"%.2f",price2];
                    cell2.price.text = price3;
                    NSString *percent3 = [NSString stringWithFormat:@"%.2f",percent2];
                    cell2.pricepercent.text = [percent3 stringByAppendingString:@"%"];
                }
            } else if (indexPath.row ==4) {
                NSString *string  = _dic[@"new_cmyl"];
                NSArray *dataArr = [string componentsSeparatedByString:@","];

                cell2.name.text = dataArr[1];
                NSString *zhangfu = [NSString stringWithFormat:@"%@",dataArr[5]];
                float n = [zhangfu floatValue];
                NSString *zhangfu2 = [NSString stringWithFormat:@"%.2f",n];
                cell2.zhangfu.text = [zhangfu2 stringByAppendingString:@"%"];
                if (n>0||n==0) {
                    cell2.zhangfu.textColor = RGB(254, 63, 77);
                } else {
                    cell2.zhangfu.textColor = RGB(34, 172, 56);
                }
                
                cell2.stockname.text = dataArr[12];
                NSString *price1 = [NSString stringWithFormat:@"%@",dataArr[11]];
                float price2 = [price1 floatValue];
                
                NSString *percent1 = [NSString stringWithFormat:@"%@",dataArr[9]];
                float percent2 = [percent1 floatValue];
                
                if (price2>0||price2==0) {
                    NSString *price3 = [NSString stringWithFormat:@"+%.2f",price2];
                    cell2.price.text = price3;
                    NSString *percent3 = [NSString stringWithFormat:@"+%.2f",percent2];
                    cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
                } else {
                    cell2.price.text =[NSString stringWithFormat:@"%.2f",price2];
                    NSString *percent3 =[NSString stringWithFormat:@"%.2f",percent2];
                    cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
                }
            } else {
                NSString *string  =_dic[@"new_jrhy"];
                NSArray *dataArr =[string componentsSeparatedByString:@","];
                
                cell2.name.text =dataArr[1];
                NSString *zhangfu =[NSString stringWithFormat:@"%@",dataArr[5]];
                float n =[zhangfu floatValue];
                NSString *zhangfu2 =[NSString stringWithFormat:@"%.2f",n];
                cell2.zhangfu.text =[zhangfu2 stringByAppendingString:@"%"];
                if (n>0||n==0) {
                    cell2.zhangfu.textColor =RGB(254, 63, 77);
                } else {
                    cell2.zhangfu.textColor =RGB(34, 172, 56);
                }
                
                cell2.stockname.text =dataArr[12];
                NSString *price1 =[NSString stringWithFormat:@"%@",dataArr[11]];
                float price2 =[price1 floatValue];
                
                NSString *percent1 =[NSString stringWithFormat:@"%@",dataArr[9]];
                float percent2 =[percent1 floatValue];
                
                if (price2>0||price2==0) {
                    NSString *price3 =[NSString stringWithFormat:@"+%.2f",price2];
                    cell2.price.text =price3;
                    
                    NSString *percent3 =[NSString stringWithFormat:@"+%.2f",percent2];
                    cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
                } else {
                    NSString *price3 =[NSString stringWithFormat:@"%.2f",price2];
                    cell2.price.text =price3;
                    NSString *percent3 =[NSString stringWithFormat:@"%.2f",percent2];
                    cell2.pricepercent.text =[percent3 stringByAppendingString:@"%"];
                }
            }
        }

        return cell2;
        
    } else {
        // 涨幅榜
        SJThreesectionCollectionCell *cell3 = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell3" forIndexPath:indexPath];
        if (self.arr.count > indexPath.row) {
            NSDictionary *dic = self.arr[indexPath.row];
            SJLog(@"%@",dic);
            cell3.code.text = [NSString stringWithFormat:@"%@",dic[@"code"]];
            cell3.name.text = [NSString stringWithFormat:@"%@",dic[@"name"]];
            NSString *change = [NSString stringWithFormat:@"%@",dic[@"changepercent"]];
            float change1 = [change floatValue];
            NSString *change2 = [NSString stringWithFormat:@"+%.2f",change1];
            cell3.changepercent.text = [change2 stringByAppendingString:@"%"];
            NSString *price = [NSString stringWithFormat:@"%@",dic[@"trade"]];
            float price1 = [price floatValue];
            cell3.currentprice.text = [NSString stringWithFormat:@"%.2f",price1];
        }
        
        return cell3;
    }
}
//返回每个分组的头高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return CGSizeMake(0, 0);
    } else {
        return CGSizeMake(0, 30);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

//返回每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return CGSizeMake((SJScreenW)/3, 87);
    } else if (indexPath.section==1) {
        return CGSizeMake(SJScreenW/3, 105);
    } else {
        return CGSizeMake(SJScreenW, 50);
    }
}
//设值每个cell的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
//设置没组的headview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SJHeadcollectvc *headvc =[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headvc" forIndexPath:indexPath];
    headvc.delegate =self;
    if (indexPath.section==1) {
        headvc.namelable.text =@"热门行业";
        headvc.Morebtn.tag=107;
        headvc.Morebtn.hidden = YES;
    } else {
        headvc.namelable.text =@"涨幅榜";
        headvc.Morebtn.tag =108;
        headvc.Morebtn.hidden = NO;
    }
    
    return headvc;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //大盘
    if (indexPath.section == 0) {
//        NSDictionary *dict = self.arr[indexPath.row];
//        NSString *symbol = dict[@"symbol"];
//        NSString *type = [symbol substringToIndex:2];
//        NSString *code = [NSString stringWithFormat:@"%@",dict[@"code"]];
//        NSString *name = dict[@"name"];
//
//        SJStockDetailContentViewController *stockDetailVC = [[SJStockDetailContentViewController alloc] init];
//        stockDetailVC.code = code;
//        stockDetailVC.type = type;
//        stockDetailVC.name = name;
//        [self.navigationController pushViewController:stockDetailVC animated:YES];
    }
    
    //热门行业
    else if (indexPath.section == 1) {
//        NSDictionary *dict = self.arr[indexPath.row];
//        NSString *symbol = dict[@"symbol"];
//        NSString *type = [symbol substringToIndex:2];
//        NSString *code = [NSString stringWithFormat:@"%@",dict[@"code"]];
//        NSString *name = dict[@"name"];
//        
//        SJStockDetailContentViewController *stockDetailVC = [[SJStockDetailContentViewController alloc] init];
//        stockDetailVC.code = code;
//        stockDetailVC.type = type;
//        stockDetailVC.name = name;
//        [self.navigationController pushViewController:stockDetailVC animated:YES];
    }
    else if (indexPath.section == 2) {
        NSDictionary *dict = self.arr[indexPath.row];
        NSString *symbol = dict[@"symbol"];
        NSString *type = [symbol substringToIndex:2];
        NSString *code = [NSString stringWithFormat:@"%@",dict[@"code"]];
        NSString *name = dict[@"name"];
        
        SJStockDetailContentViewController *stockDetailVC = [[SJStockDetailContentViewController alloc] init];
        stockDetailVC.code = code;
        stockDetailVC.type = type;
        stockDetailVC.name = name;
        [self.navigationController pushViewController:stockDetailVC animated:YES];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)morebtnClick:(UIButton *)btn {
    if (btn.tag==107) {
        // 热门行业
    } else {
        // 涨幅榜
        SJRoseController *rosevc = [[SJRoseController alloc] init];
        [self.navigationController pushViewController:rosevc animated:YES];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    SJsearchController *searchvc = [[SJsearchController alloc] init];
    [self.navigationController pushViewController:searchvc animated:YES];
    
    return NO;
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadData];
    }
}

@end

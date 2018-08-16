//
//  SJIndexCollectionViewController.m
//  CaiShiJie
//
//  Created by zhongtou on 2018/7/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJIndexCollectionViewController.h"
#import "SJFirstsectionCollectionCell.h"
#import "AFNetworking.h"
#import "SJStockDetailContentViewController.h"

@interface SJIndexCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
}
@property (nonatomic, strong) NSArray *arr4;
@property (nonatomic, strong) NSArray *arr5;
@property (nonatomic, strong) NSArray *arr6;
@property (nonatomic, assign) BOOL isNetwork;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NSDictionary *dic;
@end

@implementation SJIndexCollectionViewController


- (void)viewDidLoad {
   
    [super viewDidLoad];

    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
//        //设置headerView的尺寸大小
//        layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 100);
//        //该方法也可以设置itemSize
//        layout.itemSize =CGSizeMake(110, 150);
//
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SJScreenW, 100) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
        
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView setBackgroundColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:0.8 ]];
        
        
        //注册cell
        [_collectionView registerNib:[UINib nibWithNibName:@"SJFirstsectionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell1"];
    }

    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)loadData {
    [self loadData1];
    [self loadData2];
    [self loaddata3];
    [self loaddata6];
    [self loaddata8];
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
        self.arr6 =[str1 componentsSeparatedByString:@","];
        
        [_collectionView reloadData];
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
        
//        [self.collectionView reloadData];
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
        
//        [self.collectionView reloadData];
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
//        [self.collectionView reloadData];
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
//        [self.collectionView reloadData];
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

#pragma mark <UICollectionViewDataSource>

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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
            cell1.zhishu.textColor = RGB(34, 172, 56);
            cell1.imgvc.image =[UIImage imageNamed:@"stock_market_icon"];
        }
    }

    return cell1;

}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *dic = nil;
    switch (indexPath.row) {
        case 0:
            dic = @{@"code":@"399006",@"name":@"创业板指",@"type":@"sz"};
            break;
        case 1:
            dic = @{@"code":@"399001",@"name":@"深证成指",@"type":@"sz"};
            break;
        case 2:
            dic = @{@"code":@"000001",@"name":@"上证指数",@"type":@"sh"};
            break;
            
        default:
            break;
    }
    
    // 发送通知加载大盘指数
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMarketIndex object:dic];
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
    return CGSizeMake((SJScreenW)/3, 98);
}
    
//设值每个cell的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
   return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/





/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    if (APPDELEGATE.isNetworkReachable == YES && self.isNetwork == NO) {
        self.isNetwork = YES;
        [MBProgressHUD showMessage:@"加载中..." toView:self.view];
        [self loadData];
    }
}
    
@end

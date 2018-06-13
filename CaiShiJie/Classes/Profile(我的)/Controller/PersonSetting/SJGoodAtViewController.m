//
//  SJGoodAtViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/11.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJGoodAtViewController.h"
#import "SJPersonsettingCell.h"
#import "SJhttptool.h"
#import "NSString+SJMD5.h"
#import "MBProgressHUD+MJ.h"

@interface SJGoodAtViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString *namestring;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,copy)NSMutableArray *selectedarr;
@property (nonatomic,copy) NSArray *array;

@end

@implementation SJGoodAtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.dataSource =self;
    self.tableview.delegate =self;
    self.tableview.tableFooterView = [UIView new];
    [self getdata];
    [self setnavigationbar];
}
-(NSMutableArray *)selectedarr{
    
    if (_selectedarr==nil) {
        _selectedarr =[NSMutableArray array];
    }
    return _selectedarr;
}
-(NSArray *)array{
    if (_array ==nil) {
        _array =[NSArray array];
    }
    
    return _array;
}

-(void)getdata{
    
    _array=@[@{@"title":@"基本面分析",@"image":@"mine_xingbie_06"},
  @{@"title":@"技术面分析",@"image":@"mine_xingbie_06"},
  @{@"title":@"长线操作",@"image":@"mine_xingbie_06"},
  @{@"title":@"短线操作",@"image":@"mine_xingbie_06"},
  @{@"title":@"波段操作",@"image":@"mine_xingbie_06"},
  @{@"title":@"大盘分析",@"image":@"mine_xingbie_06"},
  @{@"title":@"行业分析",@"image":@"mine_xingbie_06"},
  @{@"title":@"个股分析",@"image":@"mine_xingbie_06"},
  @{@"title":@"价值投资",@"image":@"mine_xingbie_06"},
  @{@"title":@"热点追踪",@"image":@"mine_xingbie_06"},
  @{@"title":@"个股分析",@"image":@"mine_xingbie_06"}];
    
}
-(void)setnavigationbar{
    
    self.navigationItem.title =@"擅长领域";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
-(void)compose
{
    if (!self.selectedarr.count) {
        
        UIAlertView *view =[[UIAlertView alloc]initWithTitle:@"保存失败！" message:@"您还没有填写擅长信息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [view show];
        
        return;
    }else{
        NSLog(@"%@",self.selectedarr);
        namestring =[NSString string];
        for ( int i=0; i<self.selectedarr.count; i++) {
            NSString *num =self.selectedarr[i];
            NSInteger a=[num integerValue];
            NSDictionary *dic =_array[a];
            NSString *str =dic[@"title"];
            NSString *titlestr =[NSString  stringWithFormat:@"%@.",str];
            namestring =[namestring stringByAppendingString:titlestr];
            
        }
        
        NSString *url =[NSString stringWithFormat:@"%@/mobile/user/updatefield",HOST];
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *user_id = [d valueForKey:kUserid];
        NSString *auth_key = [d valueForKey:kAuth_key];
        NSDate *date = [NSDate date];
        NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
        
        
        NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
        
        NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",datestr,@"time",md5Auth_key,@"token",namestring,@"field",nil];
        
        [SJhttptool POST:url paramers:paramers success:^(id respose) {

            if ([respose[@"states"] isEqualToString:@"1"]) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [MBHUDHelper showWarningWithText:@"保存失败"];
            }
            
        } failure:^(NSError *error) {
            
            [MBHUDHelper showWarningWithText:@"网络不佳"];
            
            
        }];
        
        NSLog(@"%@",namestring);
        
    }
}
#pragma mark tabledalegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _array.count;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    SJPersonsettingCell *cell =[[NSBundle mainBundle]loadNibNamed:@"SJPersonsettingCell" owner:self options:nil].lastObject;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dict =_array[indexPath.row];
    if ([self.selectedarr containsObject:@(indexPath.row)]) {
        cell.image.image =[UIImage imageNamed:@"mine_xingbie_03"];
        cell.title.text =dict[@"title"];
        
        cell.content.text=nil;
         return cell;
    }else{
    
    
    cell.title.text =dict[@"title"];
    
    cell.content.text=nil;
    cell.image.image =[UIImage imageNamed:dict[@"image"]];
    return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    SJPersonsettingCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedarr containsObject:@(indexPath.row)])
    {
        cell.image.image = [UIImage imageNamed:@"mine_xingbie_06"];
        [self.selectedarr removeObject:@(indexPath.row)];
    }
    else if (self.selectedarr.count < 4)
    {
        cell.image.image = [UIImage imageNamed:@"mine_xingbie_03"];
        [self.selectedarr addObject:@(indexPath.row)];
    }
    else
    {
        [MBHUDHelper showWarningWithText:@"最多只能选择4个"];
    }
   
}


@end

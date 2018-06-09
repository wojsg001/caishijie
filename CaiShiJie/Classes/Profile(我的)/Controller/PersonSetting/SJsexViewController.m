//
//  SJsexViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJsexViewController.h"
#import "SJPersonsettingCell.h"
#import "SJhttptool.h"
#import "NSString+SJMD5.h"

@interface SJsexViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString *sexname;
}

@property (nonatomic,strong)NSArray *arr;
@property (nonatomic,strong)NSIndexPath *lastselected;

@end

@implementation SJsexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.delegate =self;
    self.tableview.dataSource =self;
   
    [self getdata];
    [self setUpNavgationBar];
}

-(NSArray *)arr{
    
    if (_arr ==nil) {
        _arr =[NSArray array];
    }
    
    return _arr;
    
}

-(void)getdata{
    
    UINib *nib2 =[UINib nibWithNibName:@"SJPersonsettingCell" bundle:[NSBundle mainBundle]];
    [self.tableview registerNib:nib2 forCellReuseIdentifier:@"cell"];
    _arr=@[@{@"title":@"男",@"image":@"mine_xingbie_03"},@{@"title":@"女",@"image":@"mine_xingbie_06"},@{@"title":@"保密",@"image":@"mine_xingbie_06"}];
    
}
-(void)setUpNavgationBar{
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];
    
    self.navigationItem.rightBarButtonItem = rightItem;

}
-(void)compose{
    if (self.lastselected==nil) {
        [sexname isEqual:@""];
        
        UIAlertView *view =[[UIAlertView alloc]initWithTitle:@"保存失败！" message:@"您还没有填写性别信息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [view show];
        
    }else{
        if (self.lastselected.row==0) {
            sexname = @"1";
        }else if (self.lastselected.row==1){
            sexname =@"2";
            
        }else if (self.lastselected.row==2){
            sexname =@"3";
        }
        
    }
    NSString *url =[NSString stringWithFormat:@"%@/mobile/user/updatesex",HOST];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    
    NSDictionary *paramers =[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"userid",md5Auth_key,@"token",datestr,@"time",sexname,@"sex",nil];
    [SJhttptool POST:url paramers:paramers success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"修改失败！"];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"网络错误！"];
    }];
}

#pragma tableviewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SJPersonsettingCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    NSDictionary *dict =_arr[indexPath.row];
    cell.title.text =dict[@"title"];
    cell.content.text=nil;
    cell.image.image =[UIImage imageNamed:dict[@"image"]];
    
    if (indexPath.row == 0)
    {
        self.lastselected = indexPath;
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    if (self.lastselected.row==indexPath.row) {
        SJPersonsettingCell *cell =[tableView cellForRowAtIndexPath:indexPath];
        
        cell.image.image =[UIImage imageNamed:@"mine_xingbie_03"];
        
        
    }else{
        SJPersonsettingCell *cell =[tableView cellForRowAtIndexPath:indexPath];
        
        cell.image.image =[UIImage imageNamed:@"mine_xingbie_03"];
        SJPersonsettingCell *cell2 =[tableView cellForRowAtIndexPath:self.lastselected];
        cell2.image.image =[UIImage imageNamed:@"mine_xingbie_06"];
        
        
        self.lastselected=indexPath;
        
    }
}

@end

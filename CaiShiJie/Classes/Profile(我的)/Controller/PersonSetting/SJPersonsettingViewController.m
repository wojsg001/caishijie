//
//  SJPersonsettingViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJPersonsettingViewController.h"
#import "SJProfileCell.h"
#import "SJPersonsettingCell.h"
#import "SJsexViewController.h"
#import "SJyearsoldviewcontroller.h"
#import "SJupdatephoneNumberVC.h"

#import "SJGoodAtViewController.h"
#import "SJinverstViewController.h"
#import "SJMyselfViewController.h"
#import "SJMyselfViewController.h"
#import "SJpersonCell.h"
#import "SJCitySelectionViewController.h"
#import "UIImageView+WebCache.h"
#import "SJNetManager.h"
#import "ZZPhotoKit.h"
#import "SJUploadParam.h"
#import "SJhttptool.h"
#import "SJToken.h"
#import "MBProgressHUD+MJ.h"
#import "MHDatePicker.h"

@interface SJPersonsettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,SJNoWifiViewDelegate>
{
    SJToken *instance;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *array0;
@property (nonatomic, strong) NSArray *array1;
@property (nonatomic, strong) NSArray *array2;
@property (nonatomic, weak) SJyearsoldviewcontroller *yearsview;
@property (strong, nonatomic) MHDatePicker *selectDatePicker;

@end

@implementation SJPersonsettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    // 设置表格
    [self setUpTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    instance = [SJToken sharedToken];
    // 加载用户信息
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadUserInfoData];
}

- (void)setUpTableView
{
    self.tableview.delegate =self;
    self.tableview.dataSource =self;
    
    UINib *nib2 =[UINib nibWithNibName:@"SJpersonCell" bundle:[NSBundle mainBundle]];
    [self.tableview registerNib:nib2 forCellReuseIdentifier:@"SJpersonCell"];
    
    UINib *nib =[UINib nibWithNibName:@"SJPersonsettingCell" bundle:[NSBundle mainBundle]];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"cell"];
}

- (void)loadUserInfoData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/find?token=%@&userid=%@&time=%@",HOST,instance.token,instance.userid,instance.time];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView hideNoWifiViewFromView:self.view];
        
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            NSDictionary *dic = respose[@"data"];
            SJLog(@"%@",dic);
            
            self.array0 = @[@{@"nickname":dic[@"nickname"],@"head_img":dic[@"head_img"]}];
            
            NSString *sex;
            if ([dic[@"sex"] isEqualToNumber:@(1)])
            {
                sex = @"男";
            }
            else if ([dic[@"sex"] isEqualToNumber:@(2)])
            {
                sex = @"女";
            }
            else
            {
                sex = @"保密";
            }
            
            NSString *birthday = [self dateStringWithDate:[NSDate dateWithTimeIntervalSince1970:[dic[@"birthday"] integerValue]] DateFormat:@"yyyy-MM-dd"];
            
            self.array1 =@[@{@"title":@"性别",@"content":sex},@{@"title":@"生日",@"content":birthday}];
            
            id value = dic[@"address"];
            NSString *city;
            if ([value isKindOfClass:[NSString class]])
            {
                city = @"";
            }
            else
            {
                city = [NSString stringWithFormat:@"%@-%@",dic[@"address"][@"province"],dic[@"address"][@"city"]];
            }
            NSString *field = dic[@"field"];
            field = [field stringByReplacingOccurrencesOfString:@"{" withString:@""];
            field = [field stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSString *investment_year = [NSString stringWithFormat:@"%@",dic[@"investment_year"]];
            NSString *phone = [NSString stringWithFormat:@"%@",dic[@"phone"]];
            NSString *qq = [NSString stringWithFormat:@"%@",dic[@"qq"]];
            
            self.array2 =@[@{@"title":@"手机号",@"content":phone},
                           @{@"title":@"QQ号",@"content":qq},
                           @{@"title":@"邮箱",@"content":dic[@"email"]},
                           @{@"title":@"所在城市",@"content":city},
                           @{@"title":@"投资年限",@"content":investment_year},
                           @{@"title":@"擅长领域",@"content":field},
                           @{@"title":@"我的简介",@"content":dic[@"introduction"]}
                           ];
            
            [self.tableview reloadData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"获取失败！"];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [SJNoWifiView showNoWifiViewToView:self.view delegate:self];
    }];
}

#pragma tableviewdelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        return self.array0.count;
        
    }else if (section==1) {
        
        return self.array1.count;
    }else {
        
        return self.array2.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    if (section==0) {
        return 10;
        
    }else{
        return 15;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        
        SJpersonCell *cell =[tableView dequeueReusableCellWithIdentifier:@"SJpersonCell"];
        NSDictionary *dict = self.array0[indexPath.row];
        [cell.headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHead_imgURL,dict[@"head_img"]]] placeholderImage:[UIImage imageNamed:@"mine_set_photo"]];
        cell.namelable.text = dict[@"nickname"];
        
        return cell;
     }else if (indexPath.section==1){
        
        SJPersonsettingCell *cells =[tableView dequeueReusableCellWithIdentifier:@"cell"];
         cells.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
         
        NSDictionary *dict =self.array1[indexPath.row];
        cells.title.text =dict[@"title"];
        cells.content.text=dict[@"content"];
         
        return cells;
        
    }else{
        
        SJPersonsettingCell *cells =[tableView dequeueReusableCellWithIdentifier:@"cell"];
        cells.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        NSDictionary *dict =self.array2[indexPath.row];
        cells.title.text =dict[@"title"];
        cells.content.text=dict[@"content"];

        return cells;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 60;
    }else{
    
    return 50;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 取消表格本身的选中状态
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) {
       UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"拍照", @"从相册选择", nil];
        
        [sheet showInView:SJKeyWindow];
        
            
    }else if (indexPath.section==1){
        
        if (indexPath.row==0) {
            SJsexViewController *sexvc =[[SJsexViewController alloc]initWithNibName:@"SJsexViewController" bundle:nil];
            sexvc.title = @"性别设置";
            [self.navigationController pushViewController:sexvc animated:YES];
            
            
        }else if (indexPath.row==1){
            // 修改用户生日
            _selectDatePicker = [[MHDatePicker alloc] init];
            _selectDatePicker.isBeforeTime = YES;
            _selectDatePicker.datePickerMode = UIDatePickerModeDate;
            
            [_selectDatePicker didFinishSelectedDate:^(NSDate *selectDataTime) {
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/updatebirthday",HOST];
                NSString *birthday = [NSString stringWithFormat:@"%ld",(long)[selectDataTime timeIntervalSince1970]];
                NSDictionary *dic = @{@"birthday":birthday,@"token":instance.token,@"userid":instance.userid,@"time":instance.time};
                [SJhttptool POST:urlStr paramers:dic success:^(id respose) {
                    if ([respose[@"states"] isEqualToString:@"1"])
                    {
                        [MBProgressHUD showSuccess:@"修改成功！"];
                        [self loadUserInfoData];
                    }
                    else
                    {
                        [MBHUDHelper showWarningWithText:@"修改失败！"];
                    }
                } failure:^(NSError *error) {
                    [MBHUDHelper showWarningWithText:@"网络错误！"];
                }];
            }];
        }
   
    }else{
        
        //第三组
        if (indexPath.row==0) {
            
            SJupdatephoneNumberVC *updatavc =[[SJupdatephoneNumberVC alloc]initWithNibName:@"SJupdatephoneNumberVC" bundle:nil];
            updatavc.title=@"修改号码";
            
            [self.navigationController pushViewController:updatavc animated:YES];
            
        }else if (indexPath.row==1){
            SJyearsoldviewcontroller *years =[[SJyearsoldviewcontroller alloc]initWithNibName:@"SJyearsoldviewcontroller" bundle:nil];
            
            years.title =@"QQ号设置";
            [self.navigationController pushViewController:years animated:YES];
            
            
        }else if (indexPath.row==2){
            
            SJupdatephoneNumberVC *updatavc =[[SJupdatephoneNumberVC alloc]initWithNibName:@"SJupdatephoneNumberVC" bundle:nil];
            updatavc.title=@"邮箱设置";
            
            [self.navigationController pushViewController:updatavc animated:YES];
            
            
        }else if (indexPath.row==3){
            //所在城市
            SJCitySelectionViewController *cityVC =[[SJCitySelectionViewController alloc]initWithNibName:@"SJCitySelectionViewController" bundle:nil];
            [self.navigationController pushViewController:cityVC animated:YES];
            
            
            
        }else if (indexPath.row==4){
            
            //投资年限
          
            SJinverstViewController *inverstvc =[[SJinverstViewController alloc]initWithNibName:@"SJinverstViewController" bundle:nil];
            [self.navigationController pushViewController:inverstvc animated:YES];
            
            
            
        }else if (indexPath.row==5){
            
            //擅长领域
            SJGoodAtViewController *goodVC =[[SJGoodAtViewController alloc]initWithNibName:@"SJGoodAtViewController" bundle:nil];
            [self.navigationController pushViewController:goodVC animated:YES];
            
        }else {
            
            //我的简介
            SJMyselfViewController *myselfvc =[[SJMyselfViewController alloc]initWithNibName:@"SJMyselfViewController" bundle:nil];
            NSDictionary *dict = self.array2[indexPath.row];
            myselfvc.str = dict[@"content"];
            
            [self.navigationController pushViewController:myselfvc animated:YES];
            
        }
    }
}
#pragma markactionsheetdelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttontitle =[actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttontitle isEqualToString:@"拍照"]) {
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            ZZCameraController *cameraController = [[ZZCameraController alloc]init];
            cameraController.takePhotoOfMax = 1;
            cameraController.isSaveLocal = YES;
            [cameraController showIn:self result:^(id responseObject){
                
                NSArray *array = (NSArray *)responseObject;
                // 上传图片
                [self uploadImage:array];
            }];
            
        }
        
    }else if ([buttontitle isEqualToString:@"从相册选择"]){
        
        ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
        photoController.selectPhotoOfMax = 1;
        
        [photoController showIn:self result:^(id responseObject){
            
            NSArray *array = (NSArray *)responseObject;
            
            // 上传图片
            [self uploadImage:array];
        }];
    }
}

- (void)uploadImage:(NSArray *)array
{
    // 创建上传模型
    UIImage *image = array[0];
    SJUploadParam *uploadP = [[SJUploadParam alloc] init];
    uploadP.data = UIImageJPEGRepresentation(image, 0.00001);
    uploadP.name = @"filedata";
    uploadP.fileName = @"image.jpeg";
    uploadP.mimeType = @"image/jpeg";
    
    [[SJNetManager sharedNetManager] uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
        
        NSLog(@"%@",dict);
        if ([dict[@"status"] isEqual:@(1)])
        {
            // 修改用户头像
            [self updateUserHeaderImage:dict[@"data"]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"网络错误！"];
    }];
}

- (void)updateUserHeaderImage:(NSString *)imgName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/user/updateheadimg",HOST];
    NSDictionary *dic = @{@"headimg":imgName,@"token":instance.token,@"userid":instance.userid,@"time":instance.time};
    [SJhttptool POST:urlStr paramers:dic success:^(id respose) {
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [MBProgressHUD showSuccess:@"修改成功！"];
            [self loadUserInfoData];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"修改失败！"];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"网络错误！"];
    }];
}

- (NSString *)dateStringWithDate:(NSDate *)date DateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    NSString *str = [dateFormatter stringFromDate:date];
    return str ? str : @"";
}

#pragma mark - SJNoWifiViewDelegate
- (void)refreshNetwork {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadUserInfoData];
}

@end

//
//  SJCreateNewReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 18/3/31.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJCreateNewReferenceViewController.h"
#import "SJSettingReferenceViewController.h"
#import "SJTextView.h"
#import "ZZPhotoKit.h"
#import "SJCreatReferenceParam.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "SJUploadParam.h"
#import "SJNetManager.h"
#import "MBProgressHUD+MJ.h"
#import "MJExtension.h"

@interface SJCreateNewReferenceViewController ()<UITableViewDataSource,UITableViewDelegate,SJSettingReferenceViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) SJTextView *textView;
@property (nonatomic, strong) SJSettingReferenceViewController *settingReferenceVC;

@end

@implementation SJCreateNewReferenceViewController

- (SJTextView *)textView
{
    if (_textView == nil)
    {
        _textView = [[SJTextView alloc] init];
        _textView.frame = CGRectMake(0, 0, SJScreenW, 500);
        
        // 设置占位符
        _textView.placeHolder = @"编写内容概要吧...";
        _textView.font = [UIFont systemFontOfSize:15];
    }
    return _textView;
}

- (SJSettingReferenceViewController *)settingReferenceVC
{
    if (_settingReferenceVC == nil)
    {
        _settingReferenceVC = [[SJSettingReferenceViewController alloc] init];
        _settingReferenceVC.view.frame = CGRectMake(0, 0, SJScreenW, 210);
        _settingReferenceVC.delegate = self;
    }
    return _settingReferenceVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    
    // 监听文本框的输入
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange) name:UITextViewTextDidChangeNotification object:nil];
    
    // 添加发布按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(creatNewReference)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

#pragma mark - 创建新内参
- (void)creatNewReference
{
    NSString *title = [self.settingReferenceVC.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *price = [self.settingReferenceVC.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *startTime = [self.settingReferenceVC.startTimeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *endTime = [self.settingReferenceVC.endTimeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *summary = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (title.length == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入内参标题"];
        return;
    }
    else if (price.length == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入内参价格"];
        return;
    }
    else if (startTime.length == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入内参服务开始时间"];
        return;
    }
    else if (endTime.length == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入内参服务结束时间"];
        return;
    }
    else if ([startTime isEqualToString:endTime])
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"开始时间与结束时间不能相同"];
        return;
    }
    else if (self.settingReferenceVC.image == nil)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请选择内参封面图"];
        return;
    }
    else if (summary.length == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入内参简介"];
        return;
    }
    
    SJToken *instance = [SJToken sharedToken];
    
    [MBProgressHUD showMessage:@"正在创建，请稍后..." toView:self.view];
    // 1.创建上传模型
    SJUploadParam *uploadP = [[SJUploadParam alloc] init];
    uploadP.data = UIImageJPEGRepresentation(self.settingReferenceVC.image, 0.00001);
    uploadP.name = @"filedata";
    uploadP.fileName = @"image.jpeg";
    uploadP.mimeType = @"image/jpeg";
    
    [[SJNetManager sharedNetManager] uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
        
        //SJLog(@"%@",dict);
        if ([dict[@"status"] isEqual:@(1)])
        {
            SJCreatReferenceParam *param = [[SJCreatReferenceParam alloc] init];
            param.token = instance.token;
            param.userid = instance.userid;
            param.time = instance.time;
            param.title = title;
            param.summary = summary;
            param.price = price;
            param.startat = startTime;
            param.endat = endTime;
            param.img = dict[@"data"];
            // 所有封面图上传成功后，开始提交数据
            [self sendReferenceWith:param];
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view];
            // 显示上传错误信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)sendReferenceWith:(SJCreatReferenceParam *)param
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/reference/create",HOST];
    [SJhttptool POST:urlStr paramers:param.keyValues success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        //SJLog(@"+++%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"发布失败!"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - 文字改变的时候调用
- (void)textViewChange
{
    // 判断下textView有木有内容
    if (_textView.text.length)
    { // 有内容
        _textView.hidePlaceHolder = YES;
    }
    else
    {
        _textView.hidePlaceHolder = NO;
    }
}

- (void)setUpTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.settingReferenceVC.view;
    }
    else
    {
        return self.textView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.settingReferenceVC.view.height;
    }
    else
    {
        return self.textView.height;
    }
}

#pragma mark - SJSettingReferenceViewControllerDelegate 代理方法
- (void)didClickAddImageButton
{
    ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
    photoController.selectPhotoOfMax = 1;
    
    __weak typeof (self) weakSelf = self;
    [photoController showIn:self result:^(id responseObject) {
        
        NSArray *array = (NSArray *)responseObject;
        
        weakSelf.settingReferenceVC.image = array[0];
        
    }];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

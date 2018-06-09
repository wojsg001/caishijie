//
//  SJCreateNewBlogArticleViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/1.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJCreateNewBlogArticleViewController.h"
#import "SJBlogArticleSettingViewController.h"
#import "SJTextView.h"
#import "ZZPhotoKit.h"
#import "Masonry.h"
#import "MBProgressHUD+MJ.h"
#import "SJUploadParam.h"
#import "SJNetManager.h"
#import "SJCreatNewBlogArticle.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "MJExtension.h"
#import "SJMyBlogArticleModel.h"

@interface SJCreateNewBlogArticleViewController ()<UITableViewDelegate,UITableViewDataSource,SJBlogArticleSettingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SJTextView *textView;
@property (nonatomic, strong) SJBlogArticleSettingViewController *settingBlogArticleVC;

@property (nonatomic, strong) NSArray *imageArr;
@property (nonatomic, strong) NSMutableArray *imageUrlArr;

@end

@implementation SJCreateNewBlogArticleViewController

- (NSMutableArray *)imageUrlArr
{
    if (_imageUrlArr == nil)
    {
        _imageUrlArr = [NSMutableArray array];
    }
    return _imageUrlArr;
}

- (SJTextView *)textView
{
    if (_textView == nil)
    {
        _textView = [[SJTextView alloc] init];
        // 设置占位符
        _textView.placeHolder = @"编写内容吧...";
        _textView.font = [UIFont systemFontOfSize:15];
        
        // 监听文本框的输入
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange) name:UITextViewTextDidChangeNotification object:nil];
        // 监听文本框内容改变
        [_textView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _textView;
}

- (SJBlogArticleSettingViewController *)settingBlogArticleVC
{
    if (_settingBlogArticleVC == nil)
    {
        _settingBlogArticleVC = [[SJBlogArticleSettingViewController alloc] init];
        _settingBlogArticleVC.view.frame = CGRectMake(0, 0, SJScreenW, 667);
        _settingBlogArticleVC.delegate = self;
        
        [_settingBlogArticleVC.settingContentView addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_settingBlogArticleVC.addImageButton.mas_bottom).offset(8);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
    }
    return _settingBlogArticleVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置表格属性
    [self setUpTableView];
    
    // 添加发布按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(creatNewBlogArticle)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)setBlogArticleModel:(SJMyBlogArticleModel *)blogArticleModel
{
    _blogArticleModel = blogArticleModel;
    
    self.settingBlogArticleVC.titleTextField.text = _blogArticleModel.title;
    if ([_blogArticleModel.permissions isEqualToString:@"0"])
    {
        self.settingBlogArticleVC.publicBtn.selected = YES;
        self.settingBlogArticleVC.privateBtn.selected = NO;
        self.settingBlogArticleVC.isPublic = YES;
    }
    else
    {
        self.settingBlogArticleVC.publicBtn.selected = NO;
        self.settingBlogArticleVC.privateBtn.selected = YES;
        self.settingBlogArticleVC.isPublic = NO;
    }
    
    NSInteger index = [_blogArticleModel.type integerValue];
    switch (index) {
        case 1:
            self.settingBlogArticleVC.typeLabel.text = @"早晚评";
            self.settingBlogArticleVC.blogType = @"1";
            break;
        case 2:
            self.settingBlogArticleVC.typeLabel.text = @"抓牛股";
            self.settingBlogArticleVC.blogType = @"2";
            break;
        case 3:
            self.settingBlogArticleVC.typeLabel.text = @"晒战绩";
            self.settingBlogArticleVC.blogType = @"3";
            break;
            
        default:
            break;
    }
    
    if (_blogArticleModel.label.length)
    {
        self.settingBlogArticleVC.labelTextField.text = _blogArticleModel.label;
    }
    
}

#pragma mark - 创建新的博文
- (void)creatNewBlogArticle
{
    NSString *title = [self.settingBlogArticleVC.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *label = [self.settingBlogArticleVC.labelTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *content = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (title.length == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入博文标题"];
        return;
    }
    else if (content.length == 0 && self.imageArr.count == 0)
    {
        [self showAlertViewWithTitle:@"提示信息" message:@"请输入博文内容或选择图片"];
        return;
    }
    
    SJToken *instance = [SJToken sharedToken];
    
    SJCreatNewBlogArticle *param = [[SJCreatNewBlogArticle alloc] init];
    param.token = instance.token;
    param.userid = instance.userid;
    param.time = instance.time;
    param.title = title;
    param.state = @"0";
    param.type = self.settingBlogArticleVC.blogType;
    if (_blogArticleModel.article_id)
    {
        // 编辑草稿箱的时候需要传入
        param.articleId = _blogArticleModel.article_id;
    }
    
    if (self.settingBlogArticleVC.isPublic)
    {
        param.pms = @"0";
    }
    else
    {
        param.pms = @"1";
    }
    
    if (label.length == 0)
    {
        param.lebel = @"";
    }
    else
    {
        param.lebel = label;
    }
    
    
    // 判断是否有图片
    if (self.imageArr.count)
    {
        [MBProgressHUD showMessage:@"正在发送，请稍后..." toView:self.view];
        // 先清空数组
        [self.imageUrlArr removeAllObjects];
        // 有图片先上传图片
        for (UIImage *image in self.imageArr)
        {
            // 1.创建上传模型
            SJUploadParam *uploadP = [[SJUploadParam alloc] init];
            uploadP.data = UIImageJPEGRepresentation(image, 0.00001);
            uploadP.name = @"filedata";
            uploadP.fileName = @"image.jpeg";
            uploadP.mimeType = @"image/jpeg";
            
            [[SJNetManager sharedNetManager] uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
                
                //SJLog(@"%@",dict);
                if ([dict[@"status"] isEqual:@(1)])
                {
                    [self.imageUrlArr addObject:dict[@"data"]];
                    
                    if (self.imageUrlArr.count == self.imageArr.count)
                    {
                        NSMutableString *contentM = [content mutableCopy];
                        
                        for (NSString *imageUrl in self.imageUrlArr)
                        {
                            NSString *tmpStr = [NSString stringWithFormat:@"<img src=\"http://img.csjimg.com/%@\" />",imageUrl];
                            [contentM appendString:tmpStr];
                        }
                        // 所有图片上传成功后，发送带图片的内参
                        param.content = contentM;
                        [self sendNewBlogArticle:param];
                    }
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.view];
                    // 显示上传错误信息
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view];
                [MBHUDHelper showWarningWithText:error.localizedDescription];
            }];
        }
    }
    else
    {
        [MBProgressHUD showMessage:@"正在发送，请稍后..."];
        // 没有图片，直接发送文字内参
        param.content = content;
        [self sendNewBlogArticle:param];
    }
}

#pragma mark - 开始发送
- (void)sendNewBlogArticle:(SJCreatNewBlogArticle *)param
{
    SJLog(@"%@",param.keyValues);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/create",HOST];
    [SJhttptool POST:urlStr paramers:param.keyValues success:^(id respose) {
        
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"+++%@",respose[@"data"]);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"发布失败！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.settingBlogArticleVC removeBlogArticleTypeView];
}

#pragma mark - 处理属性改变事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
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

#pragma mark - 输入改变的时候调用
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
}

#pragma mark - UITableViewDataSource 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    return self.settingBlogArticleVC.view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.settingBlogArticleVC.view.height;
}

#pragma mark - SJAddReferenceContentViewDelegate 代理方法
- (void)didClickAddImageButton
{
    ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
    photoController.selectPhotoOfMax = 4;
    
    [photoController showIn:self result:^(id responseObject) {
        
        NSArray *array = (NSArray *)responseObject;
        
        self.imageArr = array;
        self.settingBlogArticleVC.imageArr = self.imageArr;
        
    }];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

//
//  SJAddNewReferenceViewController.m
//  CaiShiJie
//
//  Created by user on 18/3/30.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAddNewReferenceViewController.h"
#import "SJAddReferenceTitleView.h"
#import "SJTextView.h"
#import "SJAddReferenceContentView.h"
#import "Masonry.h"
#import "ZZPhotoKit.h"
#import "SJMyNeiCan.h"
#import "SJNetManager.h"
#import "SJUploadParam.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "MBProgressHUD+MJ.h"

@interface SJAddNewReferenceViewController ()<UITextViewDelegate,SJAddReferenceContentViewDelegate>
{
    SJNetManager *netManager;
}

@property (weak, nonatomic) SJAddReferenceTitleView *titleView;
@property (weak, nonatomic) SJTextView *textView;
@property (weak, nonatomic) SJAddReferenceContentView *contentView;
@property (nonatomic, strong) NSArray *imageArr;
@property (nonatomic, strong) NSMutableArray *imageUrlArr;

@end

@implementation SJAddNewReferenceViewController

- (NSMutableArray *)imageUrlArr
{
    if (_imageUrlArr == nil)
    {
        _imageUrlArr = [NSMutableArray array];
    }
    return _imageUrlArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(232, 232, 232);
    
    netManager = [SJNetManager sharedNetManager];
    
    // 添加标题
    [self setUpTitleView];
    
    // 添加contentView
    [self setUpContentView];
    
    // 添加textView
    [self setUpTextView];
    
    // 添加发布按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(compose)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

#pragma mark - 发布内参观点
- (void)compose
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length == 0 && self.imageArr.count == 0)
    {
        [MBHUDHelper showWarningWithText:@"请输入内容或选择图片！"];
        return;
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
            
            [netManager uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
                
                //SJLog(@"%@",dict);
                if ([dict[@"status"] isEqual:@(1)])
                {
                    [self.imageUrlArr addObject:dict[@"data"]];
                    
                    if (self.imageUrlArr.count == self.imageArr.count)
                    {
                        NSMutableString *content = [text mutableCopy];
                        
                        for (NSString *imageUrl in self.imageUrlArr)
                        {
                            NSString *tmpStr = [NSString stringWithFormat:@"<img src=\"http://img.csjimg.com/%@\" />",imageUrl];
                            [content appendString:tmpStr];
                        }
                        // 所有图片上传成功后，发送带图片的内参
                        [self sendReference:content];
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
                SJLog(@"%@", error);
                [MBProgressHUD hideHUDForView:self.view];
                [MBHUDHelper showWarningWithText:error.localizedDescription];
            }];
        }
    }
    else
    {
        [MBProgressHUD showMessage:@"正在发送，请稍后..."];
       // 没有图片，直接发送文字内参
        [self sendReference:text];
    }
}

#pragma mark - 发送带图片的内参
- (void)sendReference:(NSString *)content
{
    SJToken *instance = [SJToken sharedToken];
    NSDictionary *dic = @{@"token":instance.token,@"userid":instance.userid,@"time":instance.time,@"content":content,@"referenceid":_model.reference_id};
    
    NSString *urlStr =[NSString stringWithFormat:@"%@/mobile/reference/append",HOST];
    [SJhttptool POST:urlStr paramers:dic success:^(id respose) {
        
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"+++%@",respose);
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"发送失败！"];
        }
        
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 添加标题
- (void)setUpTitleView
{
    SJAddReferenceTitleView *titleView = [[SJAddReferenceTitleView alloc] init];
    _titleView = titleView;
    _titleView.titleTextField.enabled = NO;
    _titleView.titleTextField.text = _model.title;
    _titleView.titleTextField.textColor = RGB(153, 153, 153);
    
    [self.view addSubview:_titleView];
    
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
}

#pragma mark - 添加contentView
- (void)setUpContentView
{
    SJAddReferenceContentView *contentView = [[NSBundle mainBundle] loadNibNamed:@"SJAddReferenceContentView" owner:nil options:nil].lastObject;
    _contentView = contentView;
    _contentView.delegate = self;
    
    [self.view addSubview:contentView];
    
    WS(weakSelf);
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.titleView.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - SJAddReferenceContentViewDelegate 代理方法
- (void)didClickAddImageButton
{
    ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
    photoController.selectPhotoOfMax = 4;
    
    [photoController showIn:self result:^(id responseObject) {
        
        NSArray *array = (NSArray *)responseObject;
        
        self.imageArr = array;
        self.contentView.imageArr = self.imageArr;
        
    }];
}

#pragma mark - 添加textView
- (void)setUpTextView
{
    SJTextView *textView = [[SJTextView alloc] init];
    _textView = textView;
    
    // 设置占位符
    textView.placeHolder = @"编写内容吧...";
    textView.font = [UIFont systemFontOfSize:15];
    
    [self.contentView addSubview:textView];
    
    WS(weakSelf);
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.addImageButton.mas_bottom).offset(8);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(0);
    }];
    
    // 默认允许垂直方向拖拽
    _textView.alwaysBounceVertical = YES;
    
    // 监听文本框的输入
    /**
     *  Observer:谁需要监听通知
     *  name：监听的通知的名称
     *  object：监听谁发送的通知，nil:表示谁发送我都监听
     *
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange) name:UITextViewTextDidChangeNotification object:nil];
    
    // 监听拖拽
    _textView.delegate = self;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

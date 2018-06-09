//
//  SJBlogArticleSettingViewController.m
//  CaiShiJie
//
//  Created by user on 16/4/1.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJBlogArticleSettingViewController.h"
#import "SJBlogArticleTypeView.h"
#import "Masonry.h"
#import "SJhttptool.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface SJBlogArticleSettingViewController ()<UITextFieldDelegate,SJBlogArticleTypeViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgView0;
@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgView2;
@property (weak, nonatomic) IBOutlet UIImageView *imgView3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineOneHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineTwoHeight;

@property (nonatomic, strong) SJBlogArticleTypeView *blogArticleTypeView;
@property (nonatomic, strong) NSArray *typeArr;

@end

@implementation SJBlogArticleSettingViewController

- (SJBlogArticleTypeView *)blogArticleTypeView
{
    if (_blogArticleTypeView == nil)
    {
        _blogArticleTypeView = [[SJBlogArticleTypeView alloc] init];
        _blogArticleTypeView.layer.cornerRadius = 5;
        _blogArticleTypeView.layer.masksToBounds = YES;
        _blogArticleTypeView.delegate = self;
    }
    return _blogArticleTypeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleTextField.delegate = self;
    _labelTextField.delegate = self;
    self.isPublic = YES; // 默认观看权限是公开
    self.blogType = @"1"; // 默认选择早晚评
    self.titleBackgroundView.layer.cornerRadius = 5.0f;
    self.titleBackgroundView.layer.masksToBounds = YES;
    self.lineOneHeight.constant = 0.5f;
    self.lineTwoHeight.constant = 0.5f;
    
    // 请求博文类型
    [self requestBlogArticleType];
}

#pragma mark - 请求博文类型
- (void)requestBlogArticleType
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/findarticletype",HOST];
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        //SJLog(@"%@",respose);
        
        if ([respose[@"states"] isEqualToString:@"1"])
        {
            _typeArr = respose[@"data"];
        }
        else
        {
            [MBHUDHelper showWarningWithText:@"连接错误！"];
        }
        
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:@"连接错误！"];
    }];
}

#pragma mark - 点击公开按钮
- (IBAction)ClickPublicBtn:(id)sender
{
    self.isPublic = YES;
    self.privateBtn.selected = NO;
    if (self.publicBtn.selected)
    {
        return;
    }
    else
    {
        self.publicBtn.selected = YES;
    }
}

#pragma mark - 点击私密按钮
- (IBAction)ClickPrivateBtn:(id)sender
{
    self.isPublic = NO;
    self.publicBtn.selected = NO;
    if (self.privateBtn.selected)
    {
        return;
    }
    else
    {
        self.privateBtn.selected = YES;
    }
}

#pragma mark - 点击选择类型按钮
- (IBAction)ClickTypeBtn:(id)sender
{
    self.typeBtn.selected = !self.typeBtn.selected;
    
    if (self.typeBtn.selected && self.typeArr.count)
    {
        self.blogArticleTypeView.typeArr = _typeArr;
        [self.view addSubview:self.blogArticleTypeView];
        [self.typeBtn setImage:[UIImage imageNamed:@"article_icon2_h"] forState:UIControlStateNormal];
        
        WS(weakSelf);
        [self.blogArticleTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.typeBtn.mas_bottom).offset(5);
            if (self.typeArr.count == 1)
            {
                make.height.mas_equalTo(75);
            }
            else if (self.typeArr.count == 2)
            {
                make.height.mas_equalTo(120);
            }
            else if (self.typeArr.count == 3)
            {
                make.height.mas_equalTo(165);
            }
            
            make.width.mas_equalTo(200);
            make.right.equalTo(weakSelf.typeBtn.mas_right).offset(0);
        }];
        
    }
    else
    {
        [self.blogArticleTypeView removeFromSuperview];
        self.blogArticleTypeView = nil;
        [self.typeBtn setImage:[UIImage imageNamed:@"article_icon2_n"] forState:UIControlStateNormal];
    }
}

- (void)removeBlogArticleTypeView
{
    self.typeBtn.selected = NO;
    [self.blogArticleTypeView removeFromSuperview];
    self.blogArticleTypeView = nil;
    [self.typeBtn setImage:[UIImage imageNamed:@"article_icon2_n"] forState:UIControlStateNormal];
}

#pragma mark - 点击选择图片按钮
- (IBAction)ClickAddImageButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAddImageButton)])
    {
        [self.delegate didClickAddImageButton];
    }
}

- (void)setImageArr:(NSArray *)imageArr
{
    _imageArr = imageArr;
    
    [self clearImageView];
    
    for (int i = 0; i < self.imageArr.count; i++)
    {
        switch (i) {
            case 0:
                _imgView0.image = self.imageArr[i];
                break;
            case 1:
                _imgView1.image = self.imageArr[i];
                break;
            case 2:
                _imgView2.image = self.imageArr[i];
                break;
            case 3:
                _imgView3.image = self.imageArr[i];
                break;
                
            default:
                break;
        }
    }
}

- (void)clearImageView
{
    _imgView0.image = nil;
    _imgView1.image = nil;
    _imgView2.image = nil;
    _imgView3.image = nil;
}

#pragma mark - UITextFieldDelegate 代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    
    return YES;
}

#pragma mark - SJBlogArticleTypeViewDelegate 代理方法
- (void)didClickWhichOneButton:(NSInteger)index
{
    switch (index) {
        case 1:
            self.typeLabel.text = @"早晚评";
            self.blogType = @"1";
            break;
        case 2:
            self.typeLabel.text = @"抓牛股";
            self.blogType = @"2";
            break;
        case 3:
            self.typeLabel.text = @"晒战绩";
            self.blogType = @"3";
            break;
            
        default:
            break;
    }
}

@end

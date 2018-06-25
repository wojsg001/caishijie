//
//  SJLogDetailViewController.m
//  CaiShiJie
//
//  Created by user on 18/2/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLogDetailViewController.h"
#import "SJLogInfoCell.h"
#import "SJLogInfoBottomCell.h"
#import "SJNetManager.h"
#import "MJExtension.h"
#import "SJLogDetail.h"
#import "SJShareView.h"
#import <UMShare/UMShare.h>
#import "SJToken.h"
#import "SJLoginViewController.h"
#import "SJReportViewController.h"
#import <WebKit/WebKit.h>

@interface SJLogDetailViewController ()<UITableViewDataSource,UITableViewDelegate,WKNavigationDelegate,UIAlertViewDelegate,SJLogInfoBottomCellDelegate,SJShareViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSMutableArray *logDetailArr;
@property (nonatomic, strong) SJLogDetail *logDetail;

@end

@implementation SJLogDetailViewController

- (NSMutableArray *)logDetailArr {
    if (_logDetailArr == nil) {
        _logDetailArr = [NSMutableArray array];
    }
    return _logDetailArr;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(10, 0, SJScreenW - 20, SJScreenH - 70 - 128 - 64)];
        _webView.navigationDelegate = self;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"日志详情";
    // 设置表格属性
    [self setUpTableView];
    // 加载日志详情数据
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadLogDetail];
    
    // 添加分享按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"attention_list_diary_share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareLog)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

#pragma mark - 分享按钮点击事件
- (void)shareLog {
    [SJShareView showShareViewWithDelegate:self];
}

#pragma mark - SJShareDelegate Method
- (void)shareToWhereWith:(NSInteger)index {
    switch (index) {
        case 101:
        {
            // 创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            // 创建网页内容对象
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.logDetail.title descr:self.logDetail.summary thumImage:[NSString stringWithFormat:@"https://img.csjimg.com/%@",self.logDetail.head_img]];
            shareObject.webpageUrl = [NSString stringWithFormat:@"http://www.18csj.com/article/detail/%@.html",self.logDetail.article_id];
            // 分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            
            [SJShareView hideShareView];
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_QQ messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    SJLog(@"分享成功%@", error);
                    return ;
                }
                SJLog(@"分享成功%@", result);
            }];
        }
            break;
        case 102:
        {
            // 创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            // 创建网页内容对象
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.logDetail.title descr:self.logDetail.summary thumImage:[NSString stringWithFormat:@"https://img.csjimg.com/%@",self.logDetail.head_img]];
            shareObject.webpageUrl = [NSString stringWithFormat:@"http://www.18csj.com/article/detail/%@.html",self.logDetail.article_id];
            // 分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            
            [SJShareView hideShareView];
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    SJLog(@"分享成功%@", error);
                    return ;
                }
                SJLog(@"分享成功%@", result);
            }];
        }
            break;
        case 103:
        {
            NSString *shareText = [NSString stringWithFormat:@"%@%@ - %@", self.logDetail.title, [NSString stringWithFormat:@"http://www.18csj.com/article/detail/%@.html",self.logDetail.article_id], self.logDetail.summary];
            if (shareText.length > 140) {
                shareText = [shareText substringToIndex:130];
                shareText = [shareText stringByAppendingString:@"..."];
            }
            
            // 创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            messageObject.text = shareText;
            
            [SJShareView hideShareView];
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    SJLog(@"分享成功%@", error);
                    return ;
                }
                SJLog(@"分享成功%@", result);
            }];
        }
            break;
        case 104:
        {
            // 创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            // 创建网页内容对象
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.logDetail.title descr:self.logDetail.summary thumImage:[NSString stringWithFormat:@"https://img.csjimg.com/%@",self.logDetail.head_img]];
            shareObject.webpageUrl = [NSString stringWithFormat:@"http://www.18csj.com/article/detail/%@.html",self.logDetail.article_id];
            // 分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            
            [SJShareView hideShareView];
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Qzone messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    SJLog(@"分享成功%@", error);
                    return ;
                }
                SJLog(@"分享成功%@", result);
            }];
        }
            break;
        case 105:
        {
            // 创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            // 创建网页内容对象
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.logDetail.title descr:self.logDetail.summary thumImage:[NSString stringWithFormat:@"https://img.csjimg.com/%@",self.logDetail.head_img]];
            shareObject.webpageUrl = [NSString stringWithFormat:@"http://www.18csj.com/article/detail/%@.html",self.logDetail.article_id];
            // 分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            
            [SJShareView hideShareView];
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatTimeLine messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    SJLog(@"分享成功%@", error);
                    return ;
                }
                SJLog(@"分享成功%@", result);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)setUpTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *nib1 = [UINib nibWithNibName:@"SJLogInfoCell" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"SJLogInfoCell"];
    UINib *nib2 = [UINib nibWithNibName:@"SJLogInfoBottomCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"SJLogInfoBottomCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 加载日志详情数据
- (void)loadLogDetail {
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/article/detail?userid=%@&id=%@",HOST,instance.userid,self.article_id];
    if (self.isOwnArticle == YES) {
        urlStr = [NSString stringWithFormat:@"%@/mobile/article/detail?token=%@&userid=%@&time=%@&id=%@",HOST,instance.token,instance.userid,instance.time,self.article_id];
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SJLog(@"%@",urlStr);
    
    [[SJNetManager sharedNetManager] requestLogDetailDataWithUrlStr:urlStr withSuccessBlock:^(NSDictionary *dict) {
        if ([dict[@"states"] isEqual:@"1"]) {
            //SJLog(@"%@",dict[@"data"]);
            _logDetail = [SJLogDetail objectWithKeyValues:dict[@"data"]];
            [self.logDetailArr addObject:_logDetail];

            NSURL *strUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile/article?id=%@&width=%f",HOST,self.article_id,(SJScreenW - 10)]] ;
            if (self.isOwnArticle == YES) {
                strUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile/article?token=%@&userid=%@&time=%@&id=%@&width=%f",HOST,instance.token,instance.userid,instance.time,self.article_id,(SJScreenW - 10)]] ;
            }
            SJLog(@"%@",strUrl);
            NSURLRequest *request = [NSURLRequest requestWithURL:strUrl];
            [self.webView loadRequest:request];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 101;
            [alert show];
        }
        
    } andFailBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

#pragma mark - WKNavigationDelegate 代理方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        self.webView.height = [result doubleValue];
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logDetailArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        SJLogInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJLogInfoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        SJLogDetail *logDetail = self.logDetailArr[indexPath.row];
        cell.logDetail = logDetail;
    
        return cell;
    }
    else if (indexPath.section == 1)
    {
        SJLogInfoBottomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJLogInfoBottomCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.delegate = self;
        SJLogDetail *logDetail = self.logDetailArr[indexPath.row];
        cell.logDetail = logDetail;
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 70;
    }
    else if (indexPath.section == 1)
    {
        return 128;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return self.webView;
    }
    
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return self.webView.height;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
#pragma mark - SJLogInfoBottomCellDelegate 代理方法
- (void)skipToLoginView
{
    SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
    [self.navigationController pushViewController:loginVC animated:YES];
}
// 显示举报页面
- (void)showReportView
{
    SJReportViewController *reportVC = [[SJReportViewController alloc] init];
    [self.navigationController pushViewController:reportVC animated:YES];
}

#pragma mark - UIAlertViewDelegate 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
        if (buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end

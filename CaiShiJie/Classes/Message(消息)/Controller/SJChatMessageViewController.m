//
//  SJChatMessageViewController.m
//  CaiShiJie
//
//  Created by user on 18/10/10.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJChatMessageViewController.h"
#import "SJChatMessageCell.h"
#import "SJChatMessageModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SDAutoLayout.h"
#import "TLChatBoxViewController.h"
#import "SJToken.h"
#import "SJhttptool.h"
#import "SJLoginViewController.h"
#import "SJUserInfo.h"
#import "RegexKitLite.h"
#import "SJFaceHandler.h"
#import "ZZPhotoKit.h"
#import "SJUploadParam.h"
#import "SJNetManager.h"

@interface SJChatMessageViewController ()<UITableViewDelegate, UITableViewDataSource, TLChatBoxViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSInteger i;
}
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *computerFaceArray;

@end

@implementation SJChatMessageViewController

- (TLChatBoxViewController *) chatBoxVC {
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[TLChatBoxViewController alloc] init];
        [_chatBoxVC hideChatBoxMoreButtomWithIndex:2];
        [_chatBoxVC hideChatBoxMoreButtomWithIndex:3];
        [_chatBoxVC setDelegate:self];
    }
    return _chatBoxVC;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(245, 245, 248);
    [self initData];
    [self setupSubViews];
    
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    [self loadChatMessageData];
    [self.tableView addHeaderWithTarget:self action:@selector(loadChatMessageData)];
    self.tableView.headerRefreshingText = @"正在加载...";
    self.tableView.headerReleaseToRefreshText = @"松开立即加载";
    self.tableView.headerPullToRefreshText = @"下拉可以加载";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewMessageData:) name:KNotificationMQTTHaveNewData object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)initData {
    // 表情数组
    self.computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
}

- (void)setupSubViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_tableView];
    [self.view addSubview:self.chatBoxVC.view];
    WS(weakSelf);
    [self.chatBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(weakSelf.chatBoxVC.view.mas_top).offset(0);
    }];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognizerEvent:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
}

- (void)loadChatMessageData {
    i = i + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/letter/findbymsg", HOST];
    SJToken *instance = [SJToken sharedToken];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:instance.userid forKey:@"userid"];
    [params setObject:instance.token forKey:@"token"];
    [params setObject:instance.time forKey:@"time"];
    [params setObject:self.target_id forKey:@"targetid"];
    [params setObject:@(i) forKey:@"pageindex"];
    [params setObject:@(10) forKey:@"pagesize"];
    [SJhttptool GET:urlStr paramers:params success:^(id respose) {
        //SJLog(@"%@", respose);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
        if ([respose[@"status"] isEqualToString:@"1"]) {
            NSArray *tmpArray = [SJChatMessageModel objectArrayWithKeyValuesArray:respose[@"data"][@"messages"]];
            if (tmpArray.count) {
                // 处理是否显示时间
                [self handleShowTimeWithArray:tmpArray];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tmpArray.count)];
                [self.dataArray insertObjects:tmpArray atIndexes:indexSet];
                if (i == 1) {
                    [self.tableView reloadData];
                } else {
                    CGFloat offsetOfBottom = self.tableView.contentSize.height - self.tableView.contentOffset.y;
                    [self.tableView reloadData];
                    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - offsetOfBottom)];
                }
            }
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView headerEndRefreshing];
    }];
}

#pragma mark - 接收新消息通知
- (void)addNewMessageData:(NSNotification *)n {
    NSDictionary *tmpDic = (NSDictionary *)n.object;
    NSMutableDictionary *dictionary = [tmpDic mutableCopy];
    NSData *data = [NSJSONSerialization dataWithJSONObject:tmpDic[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [dictionary removeObjectForKey:@"data"];
    [dictionary setObject:jsonString forKey:@"data"];
     SJChatMessageModel *model = [SJChatMessageModel objectWithKeyValues:dictionary];
    WS(weakSelf);
    __weak __typeof(&*model)weakModel = model;
    model.model.refreshRowData = ^(SJChatMessageContentModel *contentModel) {
        contentModel.isRefresh = YES;
        [contentModel setContent:contentModel.content];
        if ([weakSelf.dataArray containsObject:weakModel]) {
            // 刷新有图片的行
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.dataArray indexOfObject:weakModel] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    if ([self.target_id isEqualToString:model.target_id]
        || [self.target_id isEqualToString:model.user_id]) {
        [self.dataArray addObject:model];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self tableViewScrollToBottom];
        // 告诉服务器清空badgeValue
        [self sendClearBadgeValueToHostWith:model];
    }
}

- (void)sendClearBadgeValueToHostWith:(SJChatMessageModel *)model {
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/message/read?target_id=%@&user_id=%@&type=%@&token=%@&time=%@", HOST, [SJUserDefaults objectForKey:kUserid], self.target_id, model.type, instance.token, instance.time];
    SJLog(@"%@", urlStr);
    [SJhttptool GET:urlStr paramers:nil success:^(id respose) {
        SJLog(@"%@", respose[@"data"]);
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
    }];
}

- (void)handleShowTimeWithArray:(NSArray *)array {
    NSDate *lastShowDate;
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    // 设置格式本地化,日期格式字符串需要知道是哪个国家的日期，才知道怎么转换
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_us"];
    fmt.dateFormat = @"yyyyMMddHHmm";
    for (SJChatMessageModel *model in array) {
        WS(weakSelf);
        __weak __typeof(&*model)weakModel = model;
        model.model.refreshRowData = ^(SJChatMessageContentModel *contentModel) {
            contentModel.isRefresh = YES;
            [contentModel setContent:contentModel.content];
            if ([weakSelf.dataArray containsObject:weakModel]) {
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.dataArray indexOfObject:weakModel] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        NSInteger interval = [model.model.created_at integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        if ([array indexOfObject:model] == 0) {
            model.model.isShowTime = YES;
            lastShowDate = date;
            continue;
        }
  
        long long difference = ([[fmt stringFromDate:date] longLongValue] - [[fmt stringFromDate:lastShowDate] longLongValue]);
        if (difference >= 5) {
            model.model.isShowTime = YES;
            lastShowDate = date;
        } else {
            model.model.isShowTime = NO;
        }
    }
}

- (void)tableViewScrollToBottom {
    if (self.dataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataArray.count-1) inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJChatMessageCell *cell = [SJChatMessageCell cellWithTableView:tableView];
    if (self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJChatMessageModel *model = self.dataArray[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SJChatMessageCell class] contentViewWidth:SJScreenW];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - TLChatBoxViewControllerDelegate
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height andDuration:(CGFloat)duration {
    [self.chatBoxVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    [self tableViewScrollToBottom];
}
/**
 *  发送消息
 *
 *  @param chatboxViewController
 *  @param message               消息
 */
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message {
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    __block NSString *text = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length == 0) {
        return;
    }
    
    [text enumerateStringsMatchedByRegex:@"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount > 0) {
            NSString *tmpString = capturedStrings[0];
            if ([self.computerFaceArray containsObject:tmpString]) {
                NSInteger index = [self.computerFaceArray indexOfObject:tmpString];
                NSString *string = tmpString;
                string = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSString *faceString = [NSString stringWithFormat:@"<img src=\"http://common.csjimg.com/emot/qq/%d.gif\" title=\"%@\">", index + 1, string];
                text = [text stringByReplacingOccurrencesOfString:tmpString withString:faceString];
            }
        }
    }];
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/letter/sendmessages", HOST];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:instance.userid forKey:@"userid"];
    [params setObject:instance.token forKey:@"token"];
    [params setObject:instance.time forKey:@"time"];
    [params setObject:self.target_id forKey:@"targetid"];
    [params setObject:text forKey:@"content"];
    [SJhttptool POST:urlStr paramers:params success:^(id respose) {
        SJLog(@"%@", respose[@"data"]);
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
        SJLog(@"%@", error);
    }];
}
/**
 *  发送图片
 *
 *  @param chatboxViewController
 *  @param itemType              更多界面类型
 */
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didSelectItem:(NSInteger)itemType {
    if (itemType == 0) {
        // 相册
        ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
        photoController.selectPhotoOfMax = 1;
        [photoController showIn:self result:^(id responseObject) {
            NSArray *array = (NSArray *)responseObject;
            UIImage *image = array[0];
            // 上传图片
            [self uploadImageWithImage:image];
        }];
    } else if (itemType == 1) {
        // 拍摄
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];//初始化
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker setDelegate:self];
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"当前设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)uploadImageWithImage:(UIImage *)image {
    SJUploadParam *uploadP = [[SJUploadParam alloc] init];
    uploadP.data = UIImageJPEGRepresentation(image, 0.00001);
    uploadP.name = @"filedata";
    uploadP.fileName = @"image.jpeg";
    uploadP.mimeType = @"image/jpeg";
    
    [[SJNetManager sharedNetManager] uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
        if ([dict[@"status"] isEqual:@(1)]) {
            [self sendImageMessage:dict[@"data"]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        SJLog(@"%@", error);
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)sendImageMessage:(NSString *)imgName {
    [MBProgressHUD showMessage:@"正在发送..." toView:self.view];
    NSString *text = [NSString stringWithFormat:@"<img src=\"http://img.csjimg.com/%@\" />",imgName];
    SJToken *instance = [SJToken sharedToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/letter/sendmessages", HOST];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:instance.userid forKey:@"userid"];
    [params setObject:instance.token forKey:@"token"];
    [params setObject:instance.time forKey:@"time"];
    [params setObject:self.target_id forKey:@"targetid"];
    [params setObject:text forKey:@"content"];
    [SJhttptool POST:urlStr paramers:params success:^(id respose) {
        [MBProgressHUD hideHUDForView:self.view];
        SJLog(@"%@", respose[@"data"]);
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
        SJLog(@"%@", error);
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    // 上传图片
    [self uploadImageWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ClickEvent
- (void)singleTapRecognizerEvent:(UITapGestureRecognizer *)tap {
    [self cancelFirstResponder];
}

- (void)cancelFirstResponder {
    [self.chatBoxVC resignFirstResponder];
}

- (void)dealloc {
    SJLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

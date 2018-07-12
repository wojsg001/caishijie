//
//  SJInteractViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/6.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJInteractViewController.h"
#import "SJMyInteractionCell.h"
#import "SJMyInteractionMessage.h"
#import "SJMyInteractionMessageFrame.h"
#import "SJInteract.h"
#import "MJExtension.h"
#import "SJNetManager.h"
#import "MJRefresh.h"
#import "SJToken.h"
#import "SJUserInfo.h"
#import "MBProgressHUD+MJ.h"
#import "TLChatBoxViewController.h"
#import "macros.h"
#import "UIView+TL.h"
#import "Masonry.h"
#import "SJLoginViewController.h"
#import "ZZPhotoKit.h"
#import "SJUploadParam.h"
#import "SJSendMoneyViewController.h"
#import "SJNavigationController.h"
#import "RegexKitLite.h"
#import "SJFaceHandler.h"
#import "SJPersonalCenterViewController.h"

@interface SJInteractViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,TLChatBoxViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    SJNetManager *netManager;
    BOOL isAtBottom; // tableView是否显示到底部
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) NSMutableArray *interactArr;
@property (nonatomic, strong) NSDictionary *liveUserDict;// 视频用户信息
@property (nonatomic, copy  ) NSString *snMin;// 最小sn
@property (nonatomic, strong) NSString *replyid;// 回复item_id
@property (nonatomic, strong) NSString *noTodayLive;// 不是今日视频
@property (nonatomic, strong) NSArray *computerFaceArray;
@property (nonatomic, strong) UIView *showMoreMessageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGR;

@end

@implementation SJInteractViewController

- (TLChatBoxViewController *) chatBoxVC
{
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[TLChatBoxViewController alloc] init];
        [_chatBoxVC setDelegate:self];
    }
    return _chatBoxVC;
}

- (UITapGestureRecognizer *) tapGR
{
    if (_tapGR == nil) {
        _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
    }
    return _tapGR;
}

- (UIView *)showMoreMessageView
{
    if (_showMoreMessageView == nil)
    {
        _showMoreMessageView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width, self.view.height - 100, 110, 40)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:_showMoreMessageView.bounds];
        imgView.image = [UIImage imageNamed:@"none_read_icon"];
        [_showMoreMessageView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 80, 30)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.text = @"底部有新消息";
        label.textAlignment = NSTextAlignmentLeft;
        [_showMoreMessageView addSubview:label];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDo:)];
        [_showMoreMessageView addGestureRecognizer:tapRecognizer];
    }
    return _showMoreMessageView;
}

- (NSMutableArray *)interactArr
{
    if (_interactArr == nil)
    {
        _interactArr = [NSMutableArray array];
    }
    return _interactArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAtBottom = YES;
    self.view.backgroundColor = RGB(244, 245, 248);
    
    // 设置tableView
    [self setUpTableView];
    netManager = [SJNetManager sharedNetManager];
    // 默认回复id为空
    self.replyid = @"";
    self.noTodayLive = @"";
    // 接收通知
    [self setUpNotification];
    // 表情数组
    self.computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    
    [self.view addGestureRecognizer:self.tapGR];
    [self.view addSubview:self.chatBoxVC.view];
    [self.chatBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
}

- (void)setUpTableView
{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadMoreOldInteractData)];
    self.tableView.headerRefreshingText = @"正在加载...";
}

- (void)setUpNotification
{
    // 接收加载互动的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInteractData:) name:KNotificationLoadInteract object:nil];
    // 接收添加互动的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInteract:) name:KNotificationAddInteract object:nil];
    // 接收取消第一响应通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelFirstResponder) name:KNotificationResignFirstResponder object:nil];
    // 接收禁止textfield编辑的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interactTextFieldStopEdit:) name:KNotificationTextFieldStopEdit object:nil];
    // 接收允许textfield编辑的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interactTextFieldAllowEdit) name:KNotificationTextFieldAllowEdit object:nil];
    // 接收添加轮询互动的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLunxunInteract:) name:KNotificationAddLunXUnInteract object:nil];
}

#pragma mark - Event Response
- (void) didTapView
{
    [self cancelFirstResponder];
}

#pragma mark - TLChatBoxViewControllerDelegate
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height andDuration:(CGFloat)duration
{
    [self.chatBoxVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    // 告诉self.view约束需要更新
    [self.view setNeedsUpdateConstraints];
    // 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}
// 发送消息
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message
{
    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    [self sendMessage:message];
    [self cancelFirstResponder];
}

- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didSelectItem:(NSInteger)itemType
{
    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    if (itemType == 0) {
        // 相册
        ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
        photoController.selectPhotoOfMax = 1;
        
        [photoController showIn:self result:^(id responseObject){
            NSArray *array = (NSArray *)responseObject;
            SJLog(@"%@",responseObject);
            UIImage *image = array[0];
            // 上传图片
            [self uploadInteractionImageWithImage:image];
        }];
    } else if (itemType == 1) {
        // 拍摄
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];//初始化
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker setDelegate:self];
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"当前设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } else if (itemType == 3) {
        SJSendMoneyViewController *sendMoneyVC = [[SJSendMoneyViewController alloc] init];
        sendMoneyVC.navigationItem.title = @"发红包";
        sendMoneyVC.target_id = self.target_id;
        SJNavigationController *navi = [[SJNavigationController alloc] initWithRootViewController:sendMoneyVC];
        [self presentViewController:navi animated:YES completion:nil];
    }
}

- (void)uploadInteractionImageWithImage:(UIImage *)image {
    // 创建上传模型
    SJUploadParam *uploadP = [[SJUploadParam alloc] init];
    uploadP.data = UIImageJPEGRepresentation(image, 0.00001);
    uploadP.name = @"filedata";
    uploadP.fileName = @"image.jpeg";
    uploadP.mimeType = @"image/jpeg";

    [netManager uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
        SJLog(@"%@",dict);
        if ([dict[@"status"] isEqual:@(1)]) {
            // 发送互动图片
            [self sendInteractionImage:dict[@"data"]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 发送互动图片
- (void)sendInteractionImage:(NSString *)imgName
{
    NSString *text = [NSString stringWithFormat:@"<img src=\"http://img.csjimg.com/%@\" />",imgName];
    SJToken *instance = [SJToken sharedToken];
    
    [MBProgressHUD showMessage:@"正在发送..." toView:self.view];
    // 发送互动
    [netManager sendInteractionWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.liveUserDict[@"user_id"] andContent:text andReplyid:self.replyid success:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        if ([dict[@"states"] isEqual:@"0"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [MBProgressHUD showSuccess:@"发送成功！"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    // 上传图片
    [self uploadInteractionImageWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - showMoreMessageView 底部有新消息点击事件
- (void)tapDo:(UITapGestureRecognizer *)g
{
    [self tableViewScrollToBottom];
}

#pragma mark - 禁止输入键盘交互
- (void)interactTextFieldStopEdit:(NSNotification *)n
{
    self.noTodayLive = n.object;
    
    self.chatBoxVC.view.userInteractionEnabled = NO;
}

#pragma mark - 允许输入键盘交互
- (void)interactTextFieldAllowEdit
{
    self.noTodayLive = @"";
    
    self.chatBoxVC.view.userInteractionEnabled = YES;
}

#pragma mark - 加载更多旧的观点数据
- (void)loadMoreOldInteractData
{
    [netManager requestMoreOldInteractionWithUserid:self.liveUserDict[@"user_id"] andLiveid:self.liveUserDict[@"live_id"] andSn:self.snMin andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        [self.tableView headerEndRefreshing];
        //NSLog(@"+++%@",dict);
        NSArray *interactArr = dict[@"interact"];
        
        if (!interactArr.count)
        {
            [self.tableView headerEndRefreshing];
            return ;
        }
        
        self.snMin = interactArr[0][@"sn"];//重新设置最小sn
        
        NSMutableArray *interactArrM = [NSMutableArray array];
        // 只取观点数据
        for (NSDictionary *tmpDict in interactArr)
        {
            if ([tmpDict[@"type"] isEqual:@(40)])
            {
                [interactArrM addObject:tmpDict];
            }
        }
        
        NSArray *messageArr = [SJMyInteractionMessage objectArrayWithKeyValuesArray:interactArrM];
        
        // 消息模型->视图模型
        NSMutableArray *messageFrames = [NSMutableArray array];
        for (SJMyInteractionMessage *message in messageArr)
        {
            SJMyInteractionMessageFrame *messageF = [[SJMyInteractionMessageFrame alloc] init];
            messageF.message = message;
            
            [messageFrames addObject:messageF];
        }
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messageArr.count)];
        
        // 把加载的旧数据放到数组最前面
        [self.interactArr insertObjects:messageFrames atIndexes:indexSet];
        
        //NSLog(@"++%@",self.opinionArr);
        
        [self.tableView reloadData];
    } andFailBlock:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 接收加载互动的通知
- (void)loadInteractData:(NSNotification *)n
{
    // 清空互动数组
    [self.interactArr removeAllObjects];
    [self.tableView reloadData];
    
    NSDictionary *dict = n.object;
    
    self.liveUserDict = dict[@"liveInfo"];
    
    NSArray *interactArr = dict[@"interact"];
    
    //NSLog(@"%@",interactArr);
    
    if (!interactArr.count) {
        
        return;
    }
    
    NSDictionary *dic = interactArr[0];
    // 存储最小sn
    self.snMin = dic[@"sn"];
    
    NSMutableArray *interactArrM = [NSMutableArray array];
    // 只取互动信息
    for (NSDictionary *tmpDict in interactArr)
    {
        if ([tmpDict[@"type"] isEqual:@"40"])
        {
            [interactArrM addObject:tmpDict];
        }
    }
    
    NSArray *messageArr = [SJMyInteractionMessage objectArrayWithKeyValuesArray:interactArrM];
    
    //NSLog(@"+++%@",interactArrM);
    
    for (SJMyInteractionMessage *message in messageArr)
    {
        SJMyInteractionMessageFrame *messageF = [[SJMyInteractionMessageFrame alloc] init];
        messageF.message = message;
        
        [self.interactArr addObject:messageF];
    }
    
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
    
}

#pragma mark - 接收添加互动的通知
- (void)addInteract:(NSNotification *)n
{
    NSDictionary *dict = n.object;
    
    SJMyInteractionMessage *message = [SJMyInteractionMessage objectWithKeyValues:dict];
    SJMyInteractionMessageFrame *messageF = [[SJMyInteractionMessageFrame alloc] init];
    messageF.message = message;
    [self.interactArr addObject:messageF];
    
    [self.tableView reloadData];
    
    if (isAtBottom == YES) {
        // 如果表格显示在底部，则继续滚动
        [self tableViewScrollToBottom];
    } else {
        // 如果表格不显示在底部，则添加添加提示按钮
        [self.view addSubview:self.showMoreMessageView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.showMoreMessageView.transform = CGAffineTransformMakeTranslation(- 110, 0);
        } completion:nil];
    }
}
#pragma mark - 接收添加轮询互动的通知
- (void)addLunxunInteract:(NSNotification *)n
{
    NSArray *arr = n.object;
    NSArray *messageArr = [SJMyInteractionMessage objectArrayWithKeyValuesArray:arr];
    
    for (SJMyInteractionMessage *message in messageArr) {
        SJMyInteractionMessageFrame *messageF = [[SJMyInteractionMessageFrame alloc] init];
        messageF.message = message;
        [self.interactArr addObject:messageF];
    }
    [self.tableView reloadData];
    
    if (isAtBottom == YES) {
        // 如果表格显示在底部，则继续滚动
        [self tableViewScrollToBottom];
    } else {
        // 如果表格不显示在底部，则添加添加提示按钮
        [self.view addSubview:self.showMoreMessageView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.showMoreMessageView.transform = CGAffineTransformMakeTranslation(- 110, 0);
        } completion:nil];
    }
}

/** 取消事件的焦点 */
- (void)cancelFirstResponder
{
    self.replyid = @"";
    
    if ([self.noTodayLive isEqual:@"1"]) {
        [self.chatBoxVC setUpChatBoxTextViewPlaceholder:@"视频已结束！"];
    } else {
        [self.chatBoxVC setUpChatBoxTextViewPlaceholder:@"开始互动吧..."];
    }
    
    [self.chatBoxVC resignFirstResponder];
}

#pragma mark - 发送消息
- (void)sendMessage:(NSString *)message
{
    __block NSString *text = message;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    [MBProgressHUD showMessage:@"正在发送..." toView:self.view];
    // 发送互动
    [netManager sendInteractionWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.liveUserDict[@"user_id"] andContent:text andReplyid:self.replyid success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:self.view];
        
        if ([dict[@"states"] isEqual:@"0"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [MBProgressHUD showSuccess:@"发送成功！"];
            [self tableViewScrollToBottom];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

- (void)tableViewScrollToBottom
{
    if (self.interactArr.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.interactArr.count-1) inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.interactArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyInteractionCell *cell = [SJMyInteractionCell cellWithTableView:tableView];
    cell.messageF = [self.interactArr objectAtIndex:indexPath.row];
    
    cell.bgBtn.tag = indexPath.row;
    [cell.bgBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 滚动的时候取消键盘
    [self cancelFirstResponder];
    if (scrollView == self.tableView) {
        CGFloat y = scrollView.contentOffset.y;
        
        if ((scrollView.contentSize.height - self.tableView.frame.size.height - y) < 1.0f) {
            isAtBottom = YES;
            
            // 如果滚动到底部，移除提示按钮
            [UIView animateWithDuration:0.3 animations:^{
                self.showMoreMessageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self.showMoreMessageView removeFromSuperview];
            }];
            
            // 如果数组中的数据超过10条，则删除10条之前的数据
            if (self.interactArr.count > 10) {
                NSRange range = {0,self.interactArr.count - 10};
                [self.interactArr removeObjectsInRange:range];
                SJMyInteractionMessageFrame *messageF = self.interactArr[0];
                self.snMin = messageF.message.sn;
                [self.tableView reloadData];
            }
        } else {
            isAtBottom = NO;
        }
    }
}

#pragma mark - 选择回复
- (void)selectBtn:(UIButton *)btn
{
    SJMyInteractionMessageFrame *messageF = self.interactArr[btn.tag];
    self.replyid = messageF.message.item_id;
    
    [self.chatBoxVC setUpChatBoxTextViewPlaceholder:[NSString stringWithFormat:@"回复:%@",messageF.message.interactM.nickname]];
    [self.chatBoxVC setUpChatBoxTextViewBecomeFirstResponder];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SJMyInteractionMessageFrame *messageF = self.interactArr[indexPath.row];
    return messageF.cellH;
}

- (void)dealloc
{
    SJLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

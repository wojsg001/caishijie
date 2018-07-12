//
//  SJOpinionViewController.m
//  CaiShiJie
//
//  Created by user on 18/4/7.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJOpinionViewController.h"
#import "SJMyIssueCell.h"
#import "SJMyIssueMessage.h"
#import "SJMyIssueMessageFrame.h"
#import "SJGiveGiftCell.h"
#import "SJGiveGiftModel.h"
#import "SJGiveGiftFrame.h"
#import "SJGiveHongBaoCell.h"
#import "SJGiveHongBaoFrame.h"
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

@interface SJOpinionViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,TLChatBoxViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    SJNetManager *netManager;
    BOOL isAtBottom; // tableView是否显示到底部
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomMargin;
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) NSArray *computerFaceArray;
@property (nonatomic, strong) NSMutableArray *opinionArr;
@property (nonatomic, strong) NSDictionary *liveUserDict;// 视频用户信息
@property (nonatomic, copy) NSString *snMin;// 最小sn
@property (nonatomic, strong) UIView *showMoreMessageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGR;

@end

@implementation SJOpinionViewController

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

- (NSMutableArray *)opinionArr
{
    if (_opinionArr == nil)
    {
        _opinionArr = [NSMutableArray array];
    }
    return _opinionArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAtBottom = YES;
    self.view.backgroundColor = RGB(244, 245, 248);
    
    // 设置tableView
    [self setUpTableView];
    // 接收通知
    [self setUpNotification];
    
    netManager = [SJNetManager sharedNetManager];
    // 表情数组
    self.computerFaceArray = [[SJFaceHandler sharedFaceHandler] getComputerFaceArray];
    
    [self.view addGestureRecognizer:self.tapGR];
    [self.view addSubview:self.chatBoxVC.view];
    [self.chatBoxVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
    self.chatBoxVC.view.hidden = YES;
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
    [self.tableView addHeaderWithTarget:self action:@selector(loadMoreOldOpinionData)];
    self.tableView.headerRefreshingText = @"正在加载...";
}

- (void)setUpNotification
{
    // 接收加载观点的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadViewData:) name:KNotificationLoadOpinion object:nil];
    // 接收添加观点的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOpinion:) name:KNotificationAddOpinion object:nil];
    // 接收取消第一响应通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelFocus) name:KNotificationResignFirstResponder object:nil];
    // 接收禁止textfield编辑的通知(为历史视频状态时)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueTextFieldStopEdit) name:KNotificationTextFieldStopEdit object:nil];
    // 接收允许textfield编辑的通知(为视频状态时)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueTextFieldAllowEdit) name:KNotificationTextFieldAllowEdit object:nil];
    // 接收添加轮询观点的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLunxunOpinion:) name:KNotificationAddLunXunOpinion object:nil];
}

#pragma mark - Event Response
- (void) didTapView
{
    [self cancelFocus];
}

#pragma mark - TLChatBoxViewControllerDelegate
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height andDuration:(CGFloat)duration
{
    [self.chatBoxVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    // 告诉self.view约束需要更新
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}
// 发送消息
- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(NSString *)message
{
    if (![[SJUserInfo sharedUserInfo] isSucessLogined]) {
        SJLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"SJLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SJLoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    [self sendMessage:message];
    [self cancelFocus];
}

- (void)chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didSelectItem:(NSInteger)itemType
{
    if (itemType == 0) {
        // 相册
        ZZPhotoController *photoController = [[ZZPhotoController alloc]init];
        photoController.selectPhotoOfMax = 1;
        [photoController showIn:self result:^(id responseObject){
            NSArray *array = (NSArray *)responseObject;
            SJLog(@"%@",responseObject);
            UIImage *image = array[0];
            // 上传图片
            [self uploadOpinionImageWithImage:image];
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
    } else if (itemType == 3) {
        SJSendMoneyViewController *sendMoneyVC = [[SJSendMoneyViewController alloc] init];
        sendMoneyVC.navigationItem.title = @"发红包";
        sendMoneyVC.target_id = self.target_id;
        SJNavigationController *navi = [[SJNavigationController alloc] initWithRootViewController:sendMoneyVC];
        [self presentViewController:navi animated:YES completion:nil];
    }
}

- (void)uploadOpinionImageWithImage:(UIImage *)image {
    // 创建上传模型
    SJUploadParam *uploadP = [[SJUploadParam alloc] init];
    uploadP.data = UIImageJPEGRepresentation(image, 0.00001);
    uploadP.name = @"filedata";
    uploadP.fileName = @"image.jpeg";
    uploadP.mimeType = @"image/jpeg";
    
    [netManager uploadImageWithUploadParam:uploadP success:^(NSDictionary *dict) {
        SJLog(@"%@",dict);
        if ([dict[@"status"] isEqual:@(1)]) {
            // 发送观点图片
            [self sendOpinionImage:dict[@"data"]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 发送观点图片
- (void)sendOpinionImage:(NSString *)imgName
{
    [MBProgressHUD showMessage:@"正在发送..." toView:self.view];
    NSString *text = [NSString stringWithFormat:@"<img src=\"http://img.csjimg.com/%@\" />",imgName];
    SJToken *instance = [SJToken sharedToken];
    // 发送观点
    [netManager sendOpinionWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.liveUserDict[@"user_id"] andContent:text success:^(NSDictionary *dict) {
        
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
    [self uploadOpinionImageWithImage:image];
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
- (void)issueTextFieldStopEdit
{
    self.chatBoxVC.view.userInteractionEnabled = NO;
}

#pragma mark - 允许输入键盘交互
- (void)issueTextFieldAllowEdit
{
    self.chatBoxVC.view.userInteractionEnabled = YES;
}

#pragma mark - 加载更多旧的观点数据
- (void)loadMoreOldOpinionData
{
    [netManager requestMoreOldOpinionWithUserid:self.liveUserDict[@"user_id"] andLiveid:self.liveUserDict[@"live_id"] andSn:self.snMin andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        [self.tableView headerEndRefreshing];
        //SJLog(@"+++%@",dict);
        NSArray *opinionArr = dict[@"opinion"];
        
        if (!opinionArr.count)
        {
            [self.tableView headerEndRefreshing];
            return ;
        }
        
        self.snMin = opinionArr[0][@"sn"];//重新设置sn
        
        NSMutableArray *opinionArrM = [NSMutableArray array];
        // 只取观点信息
        for (NSDictionary *tmpDict in opinionArr)
        {
            if ([tmpDict[@"type"] isEqual:@(21)]) {
                // 观点
                SJMyIssueMessage *opinion = [SJMyIssueMessage objectWithKeyValues:tmpDict];
                NSDictionary *dic = @{@"type":@"21",@"data":opinion};
                
                [opinionArrM addObject:dic];
            } else if ([tmpDict[@"type"] isEqual:@(1)]) {
                // 礼物
                SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
                NSDictionary *dic = @{@"type":@"1",@"data":giveGiftModel};
                
                [opinionArrM addObject:dic];
            } else if ([tmpDict[@"type"] isEqual:@(2)]) {
                // 红包
                SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
                NSDictionary *dic = @{@"type":@"2",@"data":giveGiftModel};
        
                [opinionArrM addObject:dic];
            }
            
        }
        
        // 模型->视图模型
        NSMutableArray *opinionArrFrame = [NSMutableArray array];
        for (NSDictionary *tmpDic in opinionArrM)
        {
            if ([tmpDic[@"type"] isEqualToString:@"21"]) {
                SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
                messageF.message = tmpDic[@"data"];
                messageF.isRefresh = NO;
                WS(weakSelf);
                messageF.refreshRowData = ^(SJMyIssueMessageFrame *messageF) {
                    messageF.isRefresh = YES;
                    // 计算图片大小后重新刷新行数据
                    [messageF setMessage:messageF.message];
                    [weakSelf.tableView reloadData];
                };
                NSDictionary *dic = @{@"type":@"21",@"data":messageF};
                
                [opinionArrFrame addObject:dic];
            } else if ([tmpDic[@"type"] isEqualToString:@"1"]) {
                SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
                giveGiftFrame.giveGiftModel = tmpDic[@"data"];
                NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
                
                [opinionArrFrame addObject:dic];
            } else if ([tmpDic[@"type"] isEqualToString:@"2"]) {
                SJGiveHongBaoFrame *giveHongBaoFrame = [[SJGiveHongBaoFrame alloc] init];
                giveHongBaoFrame.giveGiftModel = tmpDic[@"data"];
                NSDictionary *dic = @{@"type":@"2",@"data":giveHongBaoFrame};
                
                [opinionArrFrame addObject:dic];
            }
        }
        
        //NSLog(@"%@",opinionArrFrame);
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, opinionArrFrame.count)];
        
        // 把加载的旧数据放到数组最前面
        [self.opinionArr insertObjects:opinionArrFrame atIndexes:indexSet];
        
        //SJLog(@"++%@",self.opinionArr);
        
        [self.tableView reloadData];
    } andFailBlock:^(NSError *error) {
        [self.tableView headerEndRefreshing];
        [MBHUDHelper showWarningWithText:error.localizedDescription];
    }];
}

#pragma mark - 接收加载观点的通知
- (void)loadViewData:(NSNotification *)n
{
    NSDictionary *dict = n.object;
    
    // 清空观点数组
    [self.opinionArr removeAllObjects];
    [self.tableView reloadData];
    
    self.liveUserDict = dict[@"liveInfo"];
    //SJLog(@"+++%@",self.liveUserDict);
    // 判断当前用户是普通用户、代理还是老师
    if ([self.liveUserDict[@"identity"] isEqual:@"0"]) {
        self.tableViewBottomMargin.constant = 0;
        self.chatBoxVC.view.hidden = YES;
    } else {
        self.tableViewBottomMargin.constant = 49;
        self.chatBoxVC.view.hidden = NO;
    }
    
    NSArray *opinionArr = dict[@"opinion"];
    //SJLog(@"---%@",opinionArr);
    if (!opinionArr.count) {
        return;
    }
    
    NSDictionary *dic = opinionArr[0];
    // 存储最小sn
    self.snMin = dic[@"sn"];
    
    NSMutableArray *opinionArrM = [NSMutableArray array];
    // 只取观点信息
    for (NSDictionary *tmpDict in opinionArr)
    {
        if ([tmpDict[@"type"] isEqual:@"21"]) {
            // 观点
            SJMyIssueMessage *opinion = [SJMyIssueMessage objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"21",@"data":opinion};
            
            [opinionArrM addObject:dic];
        } else if ([tmpDict[@"type"] isEqual:@"1"]) {
            // 礼物
            SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftModel};
            
            [opinionArrM addObject:dic];
        } else if ([tmpDict[@"type"] isEqual:@"2"]) {
            // 红包
            SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"2",@"data":giveGiftModel};
            
            [opinionArrM addObject:dic];
        }
    }
    
    // 模型->视图模型
    for (NSDictionary *tmpDic in opinionArrM)
    {
        if ([tmpDic[@"type"] isEqualToString:@"21"]) {
            SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
            messageF.message = tmpDic[@"data"];
            messageF.isRefresh = NO;
            WS(weakSelf);
            messageF.refreshRowData = ^(SJMyIssueMessageFrame *messageF) {
                messageF.isRefresh = YES;
                // 计算图片大小后重新刷新行数据
                [messageF setMessage:messageF.message];
                [weakSelf.tableView reloadData];
            };
            NSDictionary *dic = @{@"type":@"21",@"data":messageF};
            
            [self.opinionArr addObject:dic];
        } else if ([tmpDic[@"type"] isEqualToString:@"1"]) {
            SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
            giveGiftFrame.giveGiftModel = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
            
            [self.opinionArr addObject:dic];
        } else if ([tmpDic[@"type"] isEqualToString:@"2"]) {
            SJGiveHongBaoFrame *giveHongBaoFrame = [[SJGiveHongBaoFrame alloc] init];
            giveHongBaoFrame.giveGiftModel = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"2",@"data":giveHongBaoFrame};
            
            [self.opinionArr addObject:dic];
        }
    }
    
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - 接收添加观点的通知
- (void)addOpinion:(NSNotification *)n
{
    NSDictionary *dict = n.object;
    
    if ([dict[@"type"] isEqual:@(21)]) {
        // 观点
        SJMyIssueMessage *message = [SJMyIssueMessage objectWithKeyValues:dict];
        SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
        messageF.message = message;
        messageF.isRefresh = NO;
        WS(weakSelf);
        messageF.refreshRowData = ^(SJMyIssueMessageFrame *messageF) {
            messageF.isRefresh = YES;
            // 计算图片大小后重新刷新行数据
            [messageF setMessage:messageF.message];
            [weakSelf.tableView reloadData];
        };
        NSDictionary *dic = @{@"type":@"21",@"data":messageF};
        
        [self.opinionArr addObject:dic];
    } else if ([dict[@"type"] isEqual:@(1)]) {
        // 礼物
        SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:dict];
        SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
        giveGiftFrame.giveGiftModel = giveGiftModel;
        NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
        
        [self.opinionArr addObject:dic];
    } else if ([dict[@"type"] isEqual:@(2)]) {
        // 红包
        SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:dict];
        SJGiveHongBaoFrame *giveHongBaoFrame = [[SJGiveHongBaoFrame alloc] init];
        giveHongBaoFrame.giveGiftModel = giveGiftModel;
        NSDictionary *dic = @{@"type":@"2",@"data":giveHongBaoFrame};
        
        [self.opinionArr addObject:dic];
    }
    // 刷新数据
    [self.tableView reloadData];
    
    if (isAtBottom == YES) {
        // 如果表格显示在底部，则继续滚动
        [self tableViewScrollToBottom];
    } else {
        // 如果表格不显示在底部，则添加提示按钮
        [self.view addSubview:self.showMoreMessageView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.showMoreMessageView.transform = CGAffineTransformMakeTranslation(- 110, 0);
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
#pragma mark - 接收添加轮询观点的通知
- (void)addLunxunOpinion:(NSNotification *)n
{
    NSArray *arr = n.object;
    
    NSMutableArray *opinionArrM = [NSMutableArray array];
    // 只取观点信息
    for (NSDictionary *tmpDict in arr)
    {
        if ([tmpDict[@"type"] isEqual:@"21"]) {
            // 观点
            SJMyIssueMessage *opinion = [SJMyIssueMessage objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"21",@"data":opinion};
            
            [opinionArrM addObject:dic];
        } else if ([tmpDict[@"type"] isEqual:@"1"]) {
            // 礼物
            SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftModel};
            
            [opinionArrM addObject:dic];
        } else if ([tmpDict[@"type"] isEqual:@"2"]) {
            // 红包
            SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"2",@"data":giveGiftModel};
            
            [opinionArrM addObject:dic];
        }
    }
    
    // 模型->视图模型
    for (NSDictionary *tmpDic in opinionArrM)
    {
        if ([tmpDic[@"type"] isEqualToString:@"21"]) {
            SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
            messageF.message = tmpDic[@"data"];
            messageF.isRefresh = NO;
            WS(weakSelf);
            messageF.refreshRowData = ^(SJMyIssueMessageFrame *messageF) {
                messageF.isRefresh = YES;
                // 计算图片大小后重新刷新行数据
                [messageF setMessage:messageF.message];
                [weakSelf.tableView reloadData];
            };
            NSDictionary *dic = @{@"type":@"21",@"data":messageF};
            
            [self.opinionArr addObject:dic];
        } else if ([tmpDic[@"type"] isEqualToString:@"1"]) {
            SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
            giveGiftFrame.giveGiftModel = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
            
            [self.opinionArr addObject:dic];
        } else if ([tmpDic[@"type"] isEqualToString:@"2"]) {
            SJGiveHongBaoFrame *giveHongBaoFrame = [[SJGiveHongBaoFrame alloc] init];
            giveHongBaoFrame.giveGiftModel = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"2",@"data":giveHongBaoFrame};
            
            [self.opinionArr addObject:dic];
        }
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
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

/** 取消事件的焦点 */
- (void)cancelFocus
{
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
    
    // 通过正则匹配表情
    [text enumerateStringsMatchedByRegex:@"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount > 0) {
            NSString *tmpString = capturedStrings[0];
            if ([self.computerFaceArray containsObject:tmpString]) {
                NSInteger index = [self.computerFaceArray indexOfObject:tmpString];
                NSString *string = tmpString;
                string = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSString *faceString = [NSString stringWithFormat:@"<img src=\"http://common.csjimg.com/emot/qq/%ld.gif\" title=\"%@\">", index + 1, string];
                text = [text stringByReplacingOccurrencesOfString:tmpString withString:faceString];
            }
        }
    }];
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    SJToken *instance = [SJToken sharedToken];
    [MBProgressHUD showMessage:@"正在发送..." toView:self.view];
    // 发送观点
    [netManager sendOpinionWithToken:instance.token andUserid:instance.userid andTime:instance.time andTargetid:self.liveUserDict[@"user_id"] andContent:text success:^(NSDictionary *dict) {
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
    if (self.opinionArr.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.opinionArr.count-1) inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 0 && [string isEqualToString:@""]) {       // delete
        if ([textField.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [textField.text characterAtIndex:location];
                if (c == '[') {
                    textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    return NO;
                }
                else if (c == ']') {
                    return YES;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.opinionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.opinionArr[indexPath.row];
    if ([dict[@"type"] isEqualToString:@"21"]) {
        SJMyIssueCell *cell = [SJMyIssueCell cellWithTableView:tableView];
        cell.messageF = dict[@"data"];
        
        return cell;
    } else if ([dict[@"type"] isEqualToString:@"1"]) {
        SJGiveGiftCell *cell = [SJGiveGiftCell cellWithTableView:tableView];
        cell.giveGiftFrame = dict[@"data"];
        
        return cell;
    } else if ([dict[@"type"] isEqualToString:@"2"]) {
        SJGiveHongBaoCell *cell = [SJGiveHongBaoCell cellWithTableView:tableView];
        cell.giveHongBaoFrame = dict[@"data"];
        
        return cell;
    }
    
    return [UITableViewCell new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.opinionArr[indexPath.row];
    if ([dict[@"type"] isEqualToString:@"21"]) {
        SJMyIssueMessageFrame *messageF = dict[@"data"];
        return messageF.cellH;
    } else if ([dict[@"type"] isEqualToString:@"1"]) {
        SJGiveGiftFrame *giveGiftFrame = dict[@"data"];
        return giveGiftFrame.cellH;
    } else if ([dict[@"type"] isEqualToString:@"2"]) {
        SJGiveHongBaoFrame *giveHongBaoFrame = dict[@"data"];
        return giveHongBaoFrame.cellH;
    }
    
    return 0;
}

#pragma mark - UIScrollViewDelegate 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        CGFloat y = scrollView.contentOffset.y;
        
        if ((scrollView.contentSize.height - self.tableView.frame.size.height - y) < 1.0f)
        {
            isAtBottom = YES;
            
            // 如果滚动到底部，移除提示按钮
            [UIView animateWithDuration:0.3 animations:^{
                
                self.showMoreMessageView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
                [self.showMoreMessageView removeFromSuperview];
                
            }];
            
            // 如果数组中的数据超过10条，则删除10条之前的数据
            if (self.opinionArr.count > 10)
            {
                NSRange range = {0,self.opinionArr.count - 10};
                [self.opinionArr removeObjectsInRange:range];
                NSDictionary *dict = self.opinionArr[0];
                if ([dict[@"type"] isEqualToString:@"21"])
                {
                    SJMyIssueMessageFrame *messageF = dict[@"data"];
                    self.snMin = messageF.message.sn;
                }
                else if ([dict[@"type"] isEqualToString:@"1"])
                {
                    SJGiveGiftFrame *giveGiftFrame = dict[@"data"];
                    self.snMin = giveGiftFrame.giveGiftModel.sn;
                }
                [self.tableView reloadData];
            }
        }
        else
        {
            isAtBottom = NO;
        }
    }
}

- (void)dealloc
{
    SJLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

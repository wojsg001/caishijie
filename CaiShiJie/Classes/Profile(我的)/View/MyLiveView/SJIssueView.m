//
//  SJIssueView.m
//  CaiShiJie
//
//  Created by user on 16/1/7.
//  Copyright © 2016年 user. All rights reserved.
//

#import "SJIssueView.h"

#import "SJMyIssueCell.h"
#import "SJMyIssueMessage.h"
#import "SJMyIssueMessageFrame.h"
#import "MJExtension.h"
#import "SJNetManager.h"
#import "MJRefresh.h"

#import "NSString+SJMD5.h"
#import "SJUserInfo.h"
#import "TLChatBoxFaceView.h"
#import "TLChatBoxMoreView.h"
#import "MBProgressHUD+MJ.h"
#import "SJInputVoiceView.h"
#import "SJSpeechRecognizerView.h"
#import <iflyMSC/IFlySpeechRecognizer.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "iflyMSC/iflyMSC.h"

#import "SJGiveGiftCell.h"
#import "SJGiveGiftModel.h"
#import "SJGiveGiftFrame.h"


@interface SJIssueView ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TLChatBoxFaceViewDelegate,TLChatBoxMoreViewDelegate,UIScrollViewDelegate,SJSpeechRecognizerViewDelegate,IFlySpeechRecognizerDelegate>
{
    // 获取键盘弹出的动画时间
    CGFloat durtion;
    SJNetManager *netManager;
    BOOL isAtBottom; // tableView是否显示到底部
}

@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UIView             *bottomView;
@property (weak, nonatomic) IBOutlet UITextField        *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;

@property (nonatomic, strong) TLChatBoxFaceView *faceView;
@property (nonatomic, strong) NSArray *faceArr;
@property (nonatomic, strong) TLChatBoxMoreView *moreView;
@property (nonatomic, strong) SJInputVoiceView *inputVoiceView; // 对讲机
@property (nonatomic, strong) SJSpeechRecognizerView *speechRecognizerView; // 语音输入

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) NSString * result;

@property (nonatomic, strong) NSMutableArray *opinionArr;
@property (nonatomic, strong) NSDictionary *liveUserDict;// 直播用户信息
@property (nonatomic, copy) NSString *snMin;// 最小sn
@property (nonatomic, strong) UIView *showMoreMessageView;

@end

@implementation SJIssueView

- (UIView *)showMoreMessageView
{
    if (_showMoreMessageView == nil)
    {
        _showMoreMessageView = [[UIView alloc] initWithFrame:CGRectMake(self.width, self.height - 100, 110, 40)];
        
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
// 对讲机
- (SJInputVoiceView *)inputVoiceView
{
    if (_inputVoiceView == nil)
    {
        _inputVoiceView = [[NSBundle mainBundle] loadNibNamed:@"SJInputVoiceView" owner:nil options:nil].lastObject;
        _inputVoiceView.frame = CGRectMake(0, self.frame.size.height, SJScreenW, 180);
    }
    return _inputVoiceView;
}
// 语音输入
- (SJSpeechRecognizerView *)speechRecognizerView
{
    if (_speechRecognizerView == nil)
    {
        _speechRecognizerView = [[NSBundle mainBundle] loadNibNamed:@"SJSpeechRecognizerView" owner:nil options:nil].lastObject;
        _speechRecognizerView.frame = CGRectMake(0, self.frame.size.height, SJScreenW, 180);
        _speechRecognizerView.delegate = self;
    }
    return _speechRecognizerView;
}

- (TLChatBoxFaceView *)faceView
{
    if (_faceView == nil)
    {
        _faceView = [[TLChatBoxFaceView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, SJScreenW, 180)];
        _faceView.delegate = self;
        
    }
    return _faceView;
}

- (TLChatBoxMoreView *)moreView
{
    if (_moreView == nil) {
        _moreView = [[TLChatBoxMoreView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, SJScreenW, 180)];
        [_moreView setDelegate:self];
        
        TLChatBoxMoreItem *photosItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"照片"
                                                                                imageName:@"sharemore_pic"];
        TLChatBoxMoreItem *takePictureItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"拍摄"
                                                                                     imageName:@"sharemore_video"];
//        TLChatBoxMoreItem *interphoneItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"实时对讲机"
//                                                                                    imageName:@"sharemore_wxtalk" ];
        TLChatBoxMoreItem *voiceItem = [TLChatBoxMoreItem createChatBoxMoreItemWithTitle:@"语音输入"
                                                                               imageName:@"sharemore_voiceinput"];
        
        [_moreView setItems:[[NSMutableArray alloc] initWithObjects:photosItem, takePictureItem, voiceItem, nil]];
    }
    return _moreView;
}

- (NSMutableArray *)opinionArr
{
    if (_opinionArr == nil)
    {
        _opinionArr = [NSMutableArray array];
    }
    return _opinionArr;
}

- (void)awakeFromNib
{
    
    isAtBottom = YES;
    
    self.backgroundColor = RGB(244, 245, 248);
    
    _textField.delegate = self;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFocus)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    netManager = [SJNetManager sharedNetManager];
    
    // 接收加载观点的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadViewData:) name:KNotificationLoadOpinion object:nil];
    // 接收添加观点的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOpinion:) name:KNotificationAddOpinion object:nil];
    // 接收取消第一响应通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelFocus) name:KNotificationResignFirstResponder object:nil];
    // 监听键盘的弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // 接收禁止textfield编辑的通知(为历史直播状态时)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueTextFieldStopEdit) name:KNotificationTextFieldStopEdit object:nil];
    // 接收允许textfield编辑的通知(为直播状态时)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueTextFieldAllowEdit) name:KNotificationTextFieldAllowEdit object:nil];
    // 接收添加轮询观点的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLunxunOpinion:) name:KNotificationAddLunXunOpinion object:nil];
    
    // 添加下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(loadMoreOldOpinionData)];
    self.tableView.headerRefreshingText = @"正在加载";
    
    self.faceArr = @[@"惊讶",@"撇嘴",@"色",@"发呆",@"得意",@"害羞",@"闭嘴",@"睡",@"大哭",@"尴尬",@"发怒",@"调皮",@"呲牙",@"微笑",@"难过",@"酷",@"折磨",@"吐",@"偷笑",@"可爱",@"白眼",@"傲慢",@"饥饿",@"困",@"惊恐",@"流汗",@"憨笑",@"大兵",@"奋斗",@"疑问",@"嘘",@"晕",@"衰",@"骷髅",@"敲打",@"再见",@"发抖",@"爱情",@"跳跳",@"猪头",@"拥抱",@"蛋糕",@"闪电",@"炸弹",@"刀",@"足球",@"便便",@"咖啡",@"饭",@"玫瑰",@"凋谢",@"爱心",@"心碎",@"礼物",@"太阳",@"月亮",@"强",@"弱",@"握手",@"飞吻",@"怄火",@"西瓜",@"冷汗",@"抠鼻",@"鼓掌",@"溴大了",@"坏笑",@"左哼哼",@"右哼哼",@"哈欠",@"鄙视",@"委屈",@"快哭了",@"阴险",@"亲亲",@"吓",@"可怜",@"菜刀",@"啤酒",@"篮球",@"乒乓",@"示爱",@"瓢虫",@"抱拳",@"勾引",@"拳头",@"差劲",@"爱你",@"NO",@"OK",@"转圈",@"磕头",@"回头",@"跳绳",@"挥手",@"激动",@"街舞",@"献吻",@"左太极",@"右太极",@"领带",@"祈祷",@"金领",@"糖果",@"红包",@"切糕",@"十一",@"万圣节",@"给力",@"围巾",@"手套",@"圣诞袜",@"铃铛",@"圣诞帽",@"圣诞树",@"圣诞老人",@"巧克力",@"福到",@"礼炮"];
}

#pragma mark - showMoreMessageView 点击事件
- (void)tapDo:(UITapGestureRecognizer *)g
{
    [self tableViewScrollToBottom];
}

#pragma mark - 禁止textfield编辑
- (void)issueTextFieldStopEdit
{
    self.textField.placeholder = @"直播结束,已不能发起互动";
    self.textField.enabled = NO;
    self.moreBtn.enabled = NO;
    self.faceBtn.enabled = NO;
}

#pragma mark - 允许textfield编辑
- (void)issueTextFieldAllowEdit
{
    self.textField.placeholder = @"互动起来吧......";
    self.textField.enabled = YES;
    self.moreBtn.enabled = YES;
    self.faceBtn.enabled = YES;
}

#pragma mark - 加载更多旧的观点数据
- (void)loadMoreOldOpinionData
{
    [netManager requestMoreOldOpinionWithUserid:self.liveUserDict[@"user_id"] andLiveid:self.liveUserDict[@"live_id"] andSn:self.snMin andPageSize:@"5" withSuccessBlock:^(NSDictionary *dict) {
        
        //NSLog(@"+++%@",dict);
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
            // 观点
            if ([tmpDict[@"type"] isEqual:@(21)])
            {
                SJMyIssueMessage *opinion = [SJMyIssueMessage objectWithKeyValues:tmpDict];
                NSDictionary *dic = @{@"type":@"21",@"data":opinion};
                
                [opinionArrM addObject:dic];
            }
            // 礼物
            if ([tmpDict[@"type"] isEqual:@(1)])
            {
                SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
                NSDictionary *dic = @{@"type":@"1",@"data":giveGiftModel};
                
                [opinionArrM addObject:dic];
            }
        }
        
        // 模型->视图模型
        NSMutableArray *opinionArrFrame = [NSMutableArray array];
        for (NSDictionary *tmpDic in opinionArrM)
        {
            if ([tmpDic[@"type"] isEqualToString:@"21"])
            {
                SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
                messageF.message = tmpDic[@"data"];
                NSDictionary *dic = @{@"type":@"21",@"data":messageF};
                
                [opinionArrFrame addObject:dic];
            }
            
            if ([tmpDic[@"type"] isEqualToString:@"1"])
            {
                SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
                giveGiftFrame.giveGiftModel = tmpDic[@"data"];
                NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
                
                [opinionArrFrame addObject:dic];
            }
        }
        
        //NSLog(@"%@",opinionArrFrame);
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, opinionArrFrame.count)];
        
        // 把加载的旧数据放到数组最前面
        [self.opinionArr insertObjects:opinionArrFrame atIndexes:indexSet];
        
        //NSLog(@"++%@",self.opinionArr);
        
        [self.tableView reloadData];
        [self.tableView headerEndRefreshing];
        
        
    } andFailBlock:^(NSError *error) {
        
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
    //NSLog(@"+++%@",self.liveUserDict);
    // 判断当前用户是普通用户、代理还是投顾

    if ([self.liveUserDict[@"identity"] isEqual:@"0"])
    {
        self.tableViewBottom.constant = 0;
        self.bottomView.hidden = YES;
    }
    else
    {
        self.tableViewBottom.constant = 54;
        self.bottomView.hidden = NO;
    }
    
    NSArray *opinionArr = dict[@"opinion"];
    
    //NSLog(@"---%@",opinionArr);
    
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
        // 观点
        if ([tmpDict[@"type"] isEqual:@"21"])
        {
            SJMyIssueMessage *opinion = [SJMyIssueMessage objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"21",@"data":opinion};
            
            [opinionArrM addObject:dic];
        }
        // 礼物
        if ([tmpDict[@"type"] isEqual:@"1"])
        {
            SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftModel};
            
            [opinionArrM addObject:dic];
        }
    }
    
    // 模型->视图模型
    for (NSDictionary *tmpDic in opinionArrM)
    {
        if ([tmpDic[@"type"] isEqualToString:@"21"])
        {
            SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
            messageF.message = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"21",@"data":messageF};
            
            [self.opinionArr addObject:dic];
        }
        
        if ([tmpDic[@"type"] isEqualToString:@"1"])
        {
            SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
            giveGiftFrame.giveGiftModel = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
            
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
    
    if ([dict[@"type"] isEqual:@(21)])
    {
        SJMyIssueMessage *message = [SJMyIssueMessage objectWithKeyValues:dict];
        SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
        messageF.message = message;
        NSDictionary *dic = @{@"type":@"21",@"data":messageF};
        
        [self.opinionArr addObject:dic];
    }
    else if ([dict[@"type"] isEqual:@(1)])
    {
        SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:dict];
        SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
        giveGiftFrame.giveGiftModel = giveGiftModel;
        NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
        
        [self.opinionArr addObject:dic];
    }
    // 刷新数据
    [self.tableView reloadData];
    
    if (isAtBottom == YES)
    {
        // 如果表格显示在底部，则继续滚动
        [self tableViewScrollToBottom];
    }
    else
    {
        // 如果表格不显示在底部，则添加提示按钮
        [self addSubview:self.showMoreMessageView];
        
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
        // 观点
        if ([tmpDict[@"type"] isEqual:@"21"])
        {
            SJMyIssueMessage *opinion = [SJMyIssueMessage objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"21",@"data":opinion};
            
            [opinionArrM addObject:dic];
        }
        // 礼物
        else if ([tmpDict[@"type"] isEqual:@"1"])
        {
            SJGiveGiftModel *giveGiftModel = [SJGiveGiftModel objectWithKeyValues:tmpDict];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftModel};
            
            [opinionArrM addObject:dic];
        }
    }
    
    // 模型->视图模型
    for (NSDictionary *tmpDic in opinionArrM)
    {
        if ([tmpDic[@"type"] isEqualToString:@"21"])
        {
            SJMyIssueMessageFrame *messageF = [[SJMyIssueMessageFrame alloc] init];
            messageF.message = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"21",@"data":messageF};
            
            [self.opinionArr addObject:dic];
        }
        
        if ([tmpDic[@"type"] isEqualToString:@"1"])
        {
            SJGiveGiftFrame *giveGiftFrame = [[SJGiveGiftFrame alloc] init];
            giveGiftFrame.giveGiftModel = tmpDic[@"data"];
            NSDictionary *dic = @{@"type":@"1",@"data":giveGiftFrame};
            
            [self.opinionArr addObject:dic];
        }
    }
    
    [self.tableView reloadData];
    
    if (isAtBottom == YES)
    {
        // 如果表格显示在底部，则继续滚动
        [self tableViewScrollToBottom];
    }
    else
    {
        // 如果表格不显示在底部，则添加添加提示按钮
        [self addSubview:self.showMoreMessageView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.showMoreMessageView.transform = CGAffineTransformMakeTranslation(- 110, 0);
            
        } completion:^(BOOL finished) {
            
        }];
    }

}

/** 取消事件的焦点 */
- (void)cancelFocus
{
    self.textField.text = nil;
    [self.textField resignFirstResponder];
    [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_n"] forState:UIControlStateNormal];
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _bottomView.transform = CGAffineTransformIdentity;
        _tableView.transform = CGAffineTransformIdentity;
        self.faceView.transform = CGAffineTransformIdentity;
        self.moreView.transform = CGAffineTransformIdentity;
        self.inputVoiceView.transform = CGAffineTransformIdentity;
        self.speechRecognizerView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        [self.faceView removeFromSuperview];
        self.faceView = nil;
        [self.moreView removeFromSuperview];
        self.moreView = nil;
        [self.inputVoiceView removeFromSuperview];
        self.inputVoiceView = nil;
        [self.speechRecognizerView removeFromSuperview];
        self.speechRecognizerView = nil;
        
    }];
}
#pragma mark - 发送消息
- (void)sendMessage:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length == 0) {
        return;
    }
    
    // 通过正则匹配表情
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if (results.count)
    {
        NSMutableArray *faceArrM = [NSMutableArray array];
        for (int i = 0; i < results.count; i++)
        {
            NSTextCheckingResult *result = results[i];
            NSString *str = [text substringWithRange:result.range];
            
            [faceArrM addObject:str];
        }
        
        for (NSString *tmpStr in faceArrM)
        {
            NSString *str = tmpStr;
            str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
            // 找到表情在数组中对应的下标
            NSInteger index = [self.faceArr indexOfObject:str];
            // 将字符串组成html代码字符串
            NSString *faceStr = [NSString stringWithFormat:@"<img src=\"http://common.csjimg.com/emot/qq/%li.gif\" title=\"%@\">",index + 1,str];
            // 将消息中的表情换为html代码字符串
            text = [text stringByReplacingOccurrencesOfString:tmpStr withString:faceStr];
            
            //NSLog(@"+++%@",text);
        }
        
        
    }
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    [MBProgressHUD showMessage:@"正在发送..."];
    
    // 发送观点
    [netManager sendOpinionWithToken:md5Auth_key andUserid:user_id andTime:datestr andTargetid:self.liveUserDict[@"user_id"] andContent:text success:^(NSDictionary *dict) {
        
        [MBProgressHUD hideHUD];
        
        if ([dict[@"states"] isEqual:@"0"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        else
        {
            [MBProgressHUD showSuccess:@"发送成功！"];
        }
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUD];
        
        NSLog(@"%@",error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alert show];
        
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


- (IBAction)sendBtnPressed:(id)sender
{
    
    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(showLoginViewFromOpinionView)])
        {
            [self.delegate showLoginViewFromOpinionView];
        }
        
        return;
    }
    
    [self sendMessage:_textField.text];
    
    [self cancelFocus];
}

#pragma mark - Notification event
- (void)keyboardFrameChange:(NSNotification *)note
{
    durtion = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 获取键盘的frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (frame.origin.y == SJScreenH) { // 没有弹出键盘
        [UIView animateWithDuration:durtion animations:^{
            
            _bottomView.transform =  CGAffineTransformIdentity;
            _tableView.transform =  CGAffineTransformIdentity;
        }];
    }else{ // 弹出键盘
        // 工具条往上移动258
        if ([_iFlySpeechRecognizer isListening])
        {
            // 结束识别
            [self endRecognizer];
            
        }
        [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_h"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:durtion animations:^{
            
            _bottomView.transform = CGAffineTransformMakeTranslation(0, -frame.size.height);
            _tableView.transform = CGAffineTransformMakeTranslation(0, -frame.size.height);
            
        } completion:^(BOOL finished) {
            
            self.faceView.transform = CGAffineTransformIdentity;
            self.moreView.transform = CGAffineTransformIdentity;
            [self.faceView removeFromSuperview];
            [self.moreView removeFromSuperview];
            self.faceView = nil;
            self.moreView = nil;
            
        }];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.opinionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.opinionArr[indexPath.row];
    if ([dict[@"type"] isEqualToString:@"21"])
    {
        SJMyIssueCell *cell = [SJMyIssueCell cellWithTableView:tableView];
        
        cell.messageF = dict[@"data"];
        
        return cell;
    }
    else if ([dict[@"type"] isEqualToString:@"1"])
    {
        SJGiveGiftCell *cell = [SJGiveGiftCell cellWithTableView:tableView];
        
        cell.giveGiftFrame = dict[@"data"];
        
        return cell;
    }
    
    return [UITableViewCell new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.opinionArr[indexPath.row];
    if ([dict[@"type"] isEqualToString:@"21"])
    {
        SJMyIssueMessageFrame *messageF = dict[@"data"];
        
        return messageF.cellH;
    }
    else if ([dict[@"type"] isEqualToString:@"1"])
    {
        SJGiveGiftFrame *giveGiftFrame = dict[@"data"];
        
        return giveGiftFrame.cellH;
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
                [self.tableView reloadData];
            }
        }
        else
        {
            isAtBottom = NO;
        }
    }
}


#pragma mark - 发送图片等信息
- (IBAction)sendImageBtnPressed:(id)sender
{
    if ([_iFlySpeechRecognizer isListening])
    {
        // 结束识别
        [self endRecognizer];
        
    }
    [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_h"] forState:UIControlStateNormal];
    [self addSubview:self.moreView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.textField resignFirstResponder];
        _bottomView.transform = CGAffineTransformMakeTranslation(0, - 180);
        _tableView.transform = CGAffineTransformMakeTranslation(0, - 180);
        self.moreView.transform = CGAffineTransformMakeTranslation(0, - 180);
        
    } completion:^(BOOL finished) {
        
        self.faceView.transform = CGAffineTransformIdentity;
        [self.faceView removeFromSuperview];
        self.faceView = nil;
        self.inputVoiceView.transform = CGAffineTransformIdentity;
        [self.inputVoiceView removeFromSuperview];
        self.inputVoiceView = nil;
        self.speechRecognizerView.transform = CGAffineTransformIdentity;
        [self.speechRecognizerView removeFromSuperview];
        self.speechRecognizerView = nil;
        
    }];
}
#pragma mark - 选择表情按钮
- (IBAction)sendFaceImageBtnPressed:(id)sender
{
    if ([_iFlySpeechRecognizer isListening])
    {
        // 结束识别
        [self endRecognizer];
        
    }
    [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_broadcast_h"] forState:UIControlStateNormal];
    [self addSubview:self.faceView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.textField resignFirstResponder];
        
        _bottomView.transform = CGAffineTransformMakeTranslation(0, - 180);
        _tableView.transform = CGAffineTransformMakeTranslation(0, - 180);
        self.faceView.transform = CGAffineTransformMakeTranslation(0, - 180);
        
    } completion:^(BOOL finished) {
        
        self.moreView.transform = CGAffineTransformIdentity;
        [self.moreView removeFromSuperview];
        self.moreView = nil;
        self.inputVoiceView.transform = CGAffineTransformIdentity;
        [self.inputVoiceView removeFromSuperview];
        self.inputVoiceView = nil;
        self.speechRecognizerView.transform = CGAffineTransformIdentity;
        [self.speechRecognizerView removeFromSuperview];
        self.speechRecognizerView = nil;
        
    }];
    
}

#pragma mark - TLChatBoxFaceViewDelegate 代理方法
- (void) chatBoxFaceViewDidSelectedFace:(TLFace *)face type:(TLFaceType)type
{
    self.textField.text = [self.textField.text stringByAppendingString:[NSString stringWithFormat:@"[%@]",face.faceName]];
}

- (void) chatBoxFaceViewDeleteButtonDown
{
    [self textField:self.textField shouldChangeCharactersInRange:NSMakeRange(self.textField.text.length - 1, 1) replacementString:@""];
}

#pragma mark - TLChatBoxMoreViewDelegate 代理方法
- (void)chatBoxMoreView:(TLChatBoxMoreView *)chatBoxMoreView didSelectItem:(TLChatBoxItem)itemType
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectImageWithType:)])
    {
        // 相片
        if (itemType == TLChatBoxItemAlbum)
        {
            [self.delegate selectImageWithType:TLChatBoxItemAlbum];
        }
        // 拍摄
        else if (itemType == TLChatBoxItemCamera)
        {
            [self.delegate selectImageWithType:TLChatBoxItemCamera];
        }
    }
    
    // 实时对讲机
    if ((int)itemType == 2)
    {
        [self addSubview:self.inputVoiceView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.inputVoiceView.transform = CGAffineTransformMakeTranslation(0, - 180);
            
        } completion:^(BOOL finished) {
            
            self.moreView.transform = CGAffineTransformIdentity;
            [self.moreView removeFromSuperview];
            
        }];
    }
    // 语音输入
    else if ((int)itemType == 3)
    {
        [self addSubview:self.speechRecognizerView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.speechRecognizerView.transform = CGAffineTransformMakeTranslation(0, - 180);
            
        } completion:^(BOOL finished) {
            
            self.moreView.transform = CGAffineTransformIdentity;
            [self.moreView removeFromSuperview];
            
            // 开启识别
            [self startRecognizer];
        }];
    }
}

#pragma mark - SJSpeechRecognizerViewDelegate 代理方法
- (void)startOrEndSpeechRecognizer:(BOOL)isEnd
{
    if (isEnd == YES)
    {
        //NSLog(@"结束识别");
        if ([_iFlySpeechRecognizer isListening])
        {
            // 结束识别
            [self endRecognizer];
            
        }
        else
        {
            // 开启识别
            [self startRecognizer];
        }
    }
    else
    {
        //NSLog(@"开始识别");
        // 开启识别
        [self startRecognizer];
    }
}

/**
 启动听写
 *****/
- (void)startRecognizer
{
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        [_textField setText:@""];
        //[_textField resignFirstResponder];

        
        if(_iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret) {
            NSLog(@"启动成功！");
        }else{
            NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
        }
    }
}

/**
 停止录音
 *****/
- (void)endRecognizer
{
    [_iFlySpeechRecognizer stopListening];
    //[_textField resignFirstResponder];
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    NSLog(@"%@",vol);
    
    if (volume == 0)
    {
        [self.speechRecognizerView setUpStartOrEndButtonWithImage:[UIImage imageNamed:@"yuyin_h1"]];
    }
    else
    {
        [self.speechRecognizerView setUpStartOrEndButtonWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"yuyin_h%d",volume/6 == 5 ? 5 : volume/6 + 1]]];
    }
    
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
    
    NSLog(@"正在录音");
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    
    NSLog(@"停止录音");
    
    [self.speechRecognizerView setUpStartOrEndButtonWithImage:[UIImage imageNamed:@"yuyin_n"]];
}

/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        
        
        if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
            }else {
                text = @"识别成功";
            }
        }else {
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            NSLog(@"%@",text);
        }
        
        NSLog(@"%@",text);
        
    }else {
        
        NSLog(@"识别结束");
        
        NSLog(@"errorCode:%d",[error errorCode]);
    }
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    _result =[NSString stringWithFormat:@"%@%@", _textField.text,resultString];
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    _textField.text = [NSString stringWithFormat:@"%@%@", _textField.text,resultFromJson];
    
    if (isLast){
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,_textField.text);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

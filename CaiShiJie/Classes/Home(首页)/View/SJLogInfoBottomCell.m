//
//  SJLogInfoBottomCell.m
//  CaiShiJie
//
//  Created by user on 18/2/18.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJLogInfoBottomCell.h"
#import "SJLogDetail.h"
#import "SJNetManager.h"
#import "MBProgressHUD+MJ.h"

#import "NSString+SJMD5.h"
#import "SJUserInfo.h"

@interface SJLogInfoBottomCell ()

// 赞
@property (weak, nonatomic) IBOutlet UILabel *praiseLabel;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

@end

@implementation SJLogInfoBottomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLogDetail:(SJLogDetail *)logDetail
{
    _logDetail = logDetail;
    
    self.praiseLabel.text = _logDetail.praise;
    
    if ([_logDetail.is_praise isEqual:@"1"])
    {
        [self.praiseBtn setTitle:@"取消赞" forState:UIControlStateNormal];
    }
    else
    {
        [self.praiseBtn setTitle:@"赞一个" forState:UIControlStateNormal];
    }

}

- (IBAction)praiseBtnPressed:(id)sender
{
    if (![[SJUserInfo sharedUserInfo] isSucessLogined])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(skipToLoginView)])
        {
            [self.delegate skipToLoginView];
        }
        
        return;
    }
    
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    // 点赞
    SJNetManager *netManager = [SJNetManager sharedNetManager];
    [netManager giveArticlePraiseWithToken:md5Auth_key andUserid:user_id andTime:datestr andItemid:self.logDetail.article_id withSuccessBlock:^(NSDictionary *dict) {
        
        if ([dict[@"states"] isEqual:@"1"])
        {
            if ([dict[@"data"] isEqualToNumber:@(1)])
            {
                [MBProgressHUD showSuccess:@"点赞成功！"];
                
                self.praiseLabel.text = [NSString stringWithFormat:@"%i",[self.praiseLabel.text intValue] + 1];
                
                [self.praiseBtn setTitle:@"取消赞" forState:UIControlStateNormal];
            }
            else if ([dict[@"data"] isEqualToNumber:@(-1)])
            {
                [MBProgressHUD showSuccess:@"取消赞成功！"];
                
                self.praiseLabel.text = [NSString stringWithFormat:@"%i",[self.praiseLabel.text intValue] - 1];
                
                [self.praiseBtn setTitle:@"赞一个" forState:UIControlStateNormal];
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:dict[@"data"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
        
    } andFailBlock:^(NSError *error) {
        
    }];
}
#pragma mark - 点击举报按钮事件
- (IBAction)reportBtnPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showReportView)])
    {
        [self.delegate showReportView];
    }
}

@end

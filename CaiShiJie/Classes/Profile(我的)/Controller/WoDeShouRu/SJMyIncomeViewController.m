//
//  SJMyIncomeViewController.m
//  CaiShiJie
//
//  Created by user on 18/1/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMyIncomeViewController.h"
#import "SJNetManager.h"
#import "NSString+SJMD5.h"

@interface SJMyIncomeViewController ()
{
    SJNetManager *netManager;
}

@property (weak, nonatomic) IBOutlet UILabel *neiCanEarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *hongBaoEarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftEarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *xiangHuoEarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *allEarningLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineOneWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineTwoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineThreeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineFourHeight;

@end

@implementation SJMyIncomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lineOneWidth.constant = 0.5f;
    self.lineTwoHeight.constant = 0.5f;
    self.lineThreeWidth.constant = 0.5f;
    self.lineFourHeight.constant = 0.5f;
    // 请求数据
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)requestData
{
    netManager = [SJNetManager sharedNetManager];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [d valueForKey:kUserid];
    NSString *auth_key = [d valueForKey:kAuth_key];
    NSDate *date = [NSDate date];
    NSString *datestr =[NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];//把时间转成时间戳
    
    NSString *md5Auth_key = [NSString md5:[NSString stringWithFormat:@"%@%@%@",user_id,datestr,auth_key]];
    
    [netManager getTeacherEarningsWithToken:md5Auth_key andUserId:user_id andTime:datestr andStart_at:@"" andEnd_at:@"" success:^(NSDictionary *dict) {
        
        NSArray *tmpArr = dict[@"order"];
        
        // 给界面赋值
        [self setUpChildrenView:tmpArr];
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
#pragma mark - 给界面赋值
- (void)setUpChildrenView:(NSArray *)arr
{
    double sum = 0.00f;
    
    for (NSDictionary *tmpDic in arr)
    {
        if ([tmpDic[@"item_type"] isEqualToNumber:@(1)])
        {
            self.giftEarningLabel.text = tmpDic[@"price"];
            
            sum += [tmpDic[@"price"] doubleValue];
        }
        else if ([tmpDic[@"item_type"] isEqualToNumber:@(2)])
        {
            self.hongBaoEarningLabel.text = tmpDic[@"price"];
            
            sum += [tmpDic[@"price"] doubleValue];
        }
        else if ([tmpDic[@"item_type"] isEqualToNumber:@(3)])
        {
            self.xiangHuoEarningLabel.text = tmpDic[@"price"];
            
            sum += [tmpDic[@"price"] doubleValue];
        }
        else if ([tmpDic[@"item_type"] isEqualToNumber:@(20)])
        {
            self.neiCanEarningLabel.text = tmpDic[@"price"];
            
            sum += [tmpDic[@"price"] doubleValue];
        }
    }
    
    self.allEarningLabel.text = [NSString stringWithFormat:@"¥%.2f",sum];
}

@end

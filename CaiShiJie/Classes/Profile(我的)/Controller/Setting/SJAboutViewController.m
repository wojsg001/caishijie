//
//  SJAboutViewController.m
//  CaiShiJie
//
//  Created by user on 16/1/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJAboutViewController.h"
#import "KINWebBrowserViewController.h"

@interface SJAboutViewController ()<KINWebBrowserDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation SJAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于";
    
    // 获取此应用的版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本%@",currentVersion];
    
    NSDictionary *dict = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                           NSForegroundColorAttributeName:RGB(0, 122, 255)};
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"用户协议" attributes:dict];
    [self.btn setAttributedTitle:title forState:UIControlStateNormal];
}

- (IBAction)btnPressed:(id)sender
{
    KINWebBrowserViewController *webBrowserVC = [KINWebBrowserViewController webBrowser];
    [webBrowserVC setDelegate:self];
    [webBrowserVC loadURLString:@"http://www.18csj.com/help/home/2"];
    webBrowserVC.tintColor = [UIColor whiteColor];
    
    [self.navigationController pushViewController:webBrowserVC animated:YES];
}

#pragma mark - KINWebBrowserDelegate
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error {
    [MBHUDHelper showWarningWithText:@"加载失败！"];
}

@end

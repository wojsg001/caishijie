//
//  SJReportSuccessViewController.m
//  CaiShiJie
//
//  Created by user on 18/2/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJReportSuccessViewController.h"

@interface SJReportSuccessViewController ()

@end

@implementation SJReportSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmBtnPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

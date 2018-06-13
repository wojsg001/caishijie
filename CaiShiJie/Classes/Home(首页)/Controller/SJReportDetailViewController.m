//
//  SJReportDetailViewController.m
//  CaiShiJie
//
//  Created by user on 16/2/17.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJReportDetailViewController.h"

#import "SJReportSuccessViewController.h"

@interface SJReportDetailViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SJReportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"举报";
    self.textView.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textView endEditing:YES];
}

#pragma mark - UITextViewDelegate 代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    if (![text isEqualToString:@""])
    {
        self.countLabel.text = [NSString stringWithFormat:@"%li/100",(long)range.location + 1];
    }
    else
    {
        self.countLabel.text = [NSString stringWithFormat:@"%li/100",(long)range.location];
    }
    
    return YES;
}

- (IBAction)submitBtnPressed:(id)sender
{
    [self.textView endEditing:YES];
    
    if (self.textView.text.length < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"请描述你所要举报的内容！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];

        return;
    }
    
    SJReportSuccessViewController *reportSuccessVC = [[SJReportSuccessViewController alloc] initWithNibName:@"SJReportSuccessViewController" bundle:nil];
    
    [self.navigationController pushViewController:reportSuccessVC animated:YES];
}

@end

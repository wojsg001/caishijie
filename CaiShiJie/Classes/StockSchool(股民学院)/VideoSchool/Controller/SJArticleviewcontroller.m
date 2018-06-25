//
//  SJArticleviewcontroller.m
//  CaiShiJie
//
//  Created by user on 18/4/25.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJArticleviewcontroller.h"

@interface SJArticleviewcontroller ()<UIWebViewDelegate>

@end

@implementation SJArticleviewcontroller

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden =NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title =self.per_name;
    UIWebView *webvc =[[UIWebView alloc]initWithFrame:self.view.bounds];
    webvc.delegate =self;
    [self.view addSubview:webvc];
    
    
    NSNumber *width =[NSNumber numberWithFloat:SJScreenW-20];
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile/video/index?id=%@&width=%@",HOST,self.per_id,width]];
       NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webvc loadRequest:request];
}

@end

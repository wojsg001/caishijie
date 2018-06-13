//
//  SJselfSelectedDefaultController.m
//  CaiShiJie
//
//  Created by user on 16/5/9.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJselfSelectedDefaultController.h"
#define KiPhone6ScreenH 667

@interface SJselfSelectedDefaultController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *margin;

@end

@implementation SJselfSelectedDefaultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.margin.constant = self.margin.constant * (SJScreenH / KiPhone6ScreenH);
}

- (IBAction)zhuceBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(btnclick:)]) {
        
        [self.delegate btnclick:sender];
    }
}

- (IBAction)loginBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(btnclick:)]) {
        
        [self.delegate btnclick:sender];
    }
}

@end

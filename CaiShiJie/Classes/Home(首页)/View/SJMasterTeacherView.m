//
//  SJMasterTeacherView.m
//  CaiShiJie
//
//  Created by user on 16/5/4.
//  Copyright © 2018年 user. All rights reserved.
//

#import "SJMasterTeacherView.h"

@interface SJMasterTeacherView ()

@end

@implementation SJMasterTeacherView

- (id)init
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"SJMasterTeacherView" owner:nil options:nil] firstObject];

    if (self)
    {
        self.HeadView.layer.cornerRadius=self.HeadView.frame.size.width/2;
        self.HeadView.layer.masksToBounds=YES;
    }
    return self;
}

@end
